# Copyright 2020 Spotify AB
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

FROM python:3.8-alpine

RUN apk update && apk --no-cache add gcc musl-dev openjdk17-jdk curl graphviz ttf-dejavu fontconfig

# Download plantuml file, Validate checksum & Move plantuml file
RUN curl -o plantuml.jar -L https://github.com/plantuml/plantuml/releases/download/v1.2023.10/plantuml-1.2023.10.jar && echo "527d28af080ae91a455e7023e1a726c7714dc98e plantuml.jar" | sha1sum -c - && mv plantuml.jar /opt/plantuml.jar

RUN pip install --upgrade pip && pip install mkdocs-techdocs-core==1.2.2

# Create script to call plantuml.jar from a location in path
#   When adding TechDocs to the Backstage Backend container, avoid this
#   error (OSError: [Errno 8] Exec format error: 'plantuml') by using the
#   following RUN command instead:
#   RUN echo '#!/bin/sh\n\njava -jar '/opt/plantuml.jar' ${@}' >> /usr/local/bin/plantuml

#   When adding TechDocs with PlantUML diagrams, to refer external puml or pu files in any markdown file,
#   eg. '!include <referencedFileName.puml>', you'll need to include the diagrams directory eg. docs in the classpath.
#   Use following RUN command instead:
#   RUN echo $'#!/bin/sh\n\njava -Dplantuml.include.path=${diagramDir} -jar '/opt/plantuml.jar ' ${@}' >> /usr/local/bin/plantuml
RUN echo $'#!/bin/sh\n\njava -jar '/opt/plantuml.jar' ${@}' >> /usr/local/bin/plantuml
RUN chmod 755 /usr/local/bin/plantuml

ENTRYPOINT [ "mkdocs" ]
