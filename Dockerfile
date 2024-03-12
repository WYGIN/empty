ARG run="ubuntu:latest"
ARG build="ubuntu:latest"
ARG builder="paketobuildpacks/builder-jammy-base"
ARG cnb_uid=1000
ARG cnb_gid=1000
ARG CNB_PLATFORM_API=0.12
ARG CNB_LIFECYCLE_PATH="/cnb/lifecycle"
ARG CNB_LAYERS_PATH="/layers"
ARG CNB_PATH="/cnb"
ARG CNB_APP_IMAGE="wygin/buildpacksample"
ARG CNB_APP_IMAGE_WORKING_DIR="/workspace"
ARG CNB_PLATFORM_DIR="/platform"

ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}
ENV CNB_PLATFORM_API=${CNB_PLATFORM_API}

FROM ${CNB_APP_IMAGE} AS app-image

FROM ${builder} AS builder-image
COPY --from="app-image" ${CNB_APP_IMAGE_WORKING_DIR} ${CNB_APP_IMAGE_WORKING_DIR}
RUN "${CNB_LIFECYCLE_PATH}/analyzer" -log-level debug -daemon -layers=${CNB_LAYERS_PATH} -run-image ${run} ${CNB_APP_IMAGE_WORKING_DIR}
RUN "${CNB_LIFECYCLE_PATH}/detector" -log-level debug -layers=${CNB_LAYERS_PATH} -order="${CNB_PATH}/order.toml" -buildpacks="${CNB_PATH}/buildpacks" -app ${APP_IMAGE_WORKING_DIR}
RUN "${CNB_LIFECYCLE_PATH}/restorer" -log-level debug -layers=${CNB_LAYERS_PATH} -group="${CNB_LAYERS_PATH}/group.toml" -cache-dir="./cache" -analyzed="${CNB_LAYERS_PATH}/analyzed.toml"
RUN "${CNB_LIFECYCLE_PATH}/builder" -log-level debug -layers=${CNB_LAYERS_PATH} -group="${CNB_LAYERS_PATH}/group.toml" -analyzed="${CNB_LAYERS_PATH}/analyzed.toml" -plan="${CNB_LAYERS_PATH}/plan.toml" -buildpacks="${CNB_PATH}/buildpacks" -app=${CNB_APP_IMAGE_WORKING_DIR} -platform=${CNB_PLATFORM_DIR}
RUN "${CNB_LIFECYCLE_PATH}/exporter" --log-level debug -launch-cache "./cache" -daemon -cache-dir "./cache" -analyzed "${CNB_LAYERS_PATH}/analyzed.toml" -group "${CNB_LAYERS_PATH}/group.toml" -layers=${CNB_LAYERS_PATH} -app ${CNB_APP_IMAGE_WORKING_DIR} -launcher="${CNB_LIFECYCLE_PATH}/launcher" -process-type="shell" ${CNB_APP_IMAGE_WORKING_DIR}

FROM ${build} as build-image
COPY --from="builder-image" / /
RUN groupadd cnb --gid ${cnb_gid} && useradd --uid ${cnb_uid} --gid ${cnb_gid} -m -s /bin/bash cnb
USER ${cnb_uid}:${cnb_gid}
ENV CNB_USER_ID=${cnb_uid}
ENV CNB_GROUP_ID=${cnb_gid}

FROM ${run}
COPY --from="builder-image" / /
# RUN groupadd cnb --gid ${cnb_gid} && useradd --uid ${cnb_uid} --gid ${cnb_gid} -m -s /bin/bash cnb
USER ${cnb_uid}:${cnb_gid}