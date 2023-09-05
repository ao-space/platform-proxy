# Copyright (c) 2022 Institute of Software Chinese Academy of Sciences (ISCAS)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM openresty/openresty:1.21.4.1-4-bullseye-fat
COPY ./conf/default.conf /etc/nginx/conf.d/default.conf
COPY ./conf/rewrite.lua /etc/nginx/conf.d/rewrite.lua
COPY ./conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY entrypoint.sh /entrypoint.sh

RUN sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
RUN apt update && apt install --no-install-recommends  -y curl && rm -rf /var/lib/apt/lists/*
RUN chmod +x /entrypoint.sh

ENV DOCKER_DNS=192.168.0.10

ENTRYPOINT ["/entrypoint.sh"]