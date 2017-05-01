/**
properties([
  parameters([
    string(defaultValue: '1.0', description: 'Current version number', name: 'VERSION'),
    text(defaultValue: '', description: 'A list of changes', name: 'CHANGES'),
    booleanParam(defaultValue: false, description: 'If build should be marked as pre-release', name: 'PRERELEASE'),
    string(defaultValue: 'ayufan-pine64', description: 'GitHub username or organization', name: 'GITHUB_USER'),
    string(defaultValue: 'android-7.1', description: 'GitHub repository', name: 'GITHUB_REPO'),
    booleanParam(defaultValue: true, description: 'Select if you want to build tablet version.', name: 'BUILD_TABLET'),
    booleanParam(defaultValue: true, description: 'Select if you want to build TV version.', name: 'BUILD_TV'),
    booleanParam(defaultValue: true, description: 'Select if you want to build Pinebook version.', name: 'BUILD_PINEBOOK'),
  ])
])
*/

node('docker && android-build') {
  timestamps {
    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
      stage "Environment"
      dir('build-environment') {
        checkout scm
      }
      def environment = docker.build('build-environment:android-7.1', 'build-environment')

      environment.inside {
        stage 'Sources'
        sh '''#!/bin/bash

        set -xe

        export HOME=$WORKSPACE
        export USER=jenkins

        repo init -u https://android.googlesource.com/platform/manifest -b android-7.1.0_r7 --depth=1
        rm -rf .repo/local_manifests
        git clone https://github.com/ayufan-pine64/local_manifests -b nougat-7.1 .repo/local_manifests

        repo sync -j 20 -c --force-sync
        '''

        withEnv([
          "VERSION=$VERSION",
          'TARGET=tulip_chiphd-userdebug',
          'USE_CCACHE=true',
          'CCACHE_DIR=/var/lib/ccache',
        ]) {
            stage 'Prepare'
            sh '''#!/bin/bash
              export CCACHE_DIR=$PWD/ccache
              prebuilts/misc/linux-x86/ccache/ccache -M 0 -F 0
              rm -f *.gz
            '''
        }

        withEnv([
          "VERSION=$VERSION",
          "CHANGES=$CHANGES",
          "GITHUB_USER=$GITHUB_USER",
          "GITHUB_REPO=$GITHUB_REPO"
        ]) {
          stage 'Freeze'
          sh '''#!/bin/bash
            # use -ve, otherwise we could leak GITHUB_TOKEN...
            set -ve
            shopt -s nullglob

            export HOME=$WORKSPACE
            export USER=jenkins

            repo manifest -r -o manifest.xml

            curl --fail -X PUT -H "Authorization: token $GITHUB_TOKEN" \
              -d "{\\"message\\":\\"Add $VERSION changes\\", \\"committer\\":{\\"name\\":\\"Jenkins\\",\\"email\\":\\"jenkins@ayufan.eu\\"},\\"content\\":\\"$(echo "$CHANGES" | base64 -w 0)\\"}" \
              "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/contents/versions/$VERSION/CHANGES.md"

            curl --fail -X PUT -H "Authorization: token $GITHUB_TOKEN" \
              -d "{\\"message\\":\\"Add $VERSION manifest\\", \\"committer\\":{\\"name\\":\\"Jenkins\\",\\"email\\":\\"jenkins@ayufan.eu\\"},\\"content\\":\\"$(base64 -w 0 manifest.xml)\\"}" \
              "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/contents/versions/$VERSION/manifest.xml"
          '''
        }

        withEnv([
          "VERSION=$VERSION",
          'TARGET=tulip_chiphd-userdebug',
          'USE_CCACHE=true',
          'ANDROID_JACK_VM_ARGS=-Xmx3g -Dfile.encoding=UTF-8 -XX:+TieredCompilation',
          'ANDROID_NO_TEST_CHECK=true'
        ]) {
          stage 'Regular'
          if (params.BUILD_TABLET) {
            sh '''#!/bin/bash
              export CCACHE_DIR=$PWD/ccache
              export HOME=$WORKSPACE
              export USER=jenkins

              source build/envsetup.sh
              lunch "${TARGET}"
              make installclean
            '''

            retry(2) {
              sh '''#!/bin/bash
                export CCACHE_DIR=$PWD/ccache
                export HOME=$WORKSPACE
                export USER=jenkins

                source build/envsetup.sh
                lunch "${TARGET}"
                make -j$(($(nproc)+1))
              '''
            }
          }

          stage 'Image Regular'
          if (params.BUILD_TABLET) {
            sh '''#!/bin/bash
              source build/envsetup.sh
              lunch "${TARGET}"
              set -xe
              sdcard_image "${JOB_NAME}-v${VERSION}-r${BUILD_NUMBER}.img.gz"
            '''
          }
        }

        withEnv([
          "VERSION=$VERSION",
          'TARGET=tulip_chiphd_pinebook-userdebug',
          'USE_CCACHE=true',
          'ANDROID_JACK_VM_ARGS=-Xmx3g -Dfile.encoding=UTF-8 -XX:+TieredCompilation',
          'ANDROID_NO_TEST_CHECK=true'
        ]) {
          stage 'Pinebook'
          if (params.BUILD_PINEBOOK) {
            sh '''#!/bin/bash
              export CCACHE_DIR=$PWD/ccache
              export HOME=$WORKSPACE
              export USER=jenkins

              source build/envsetup.sh
              lunch "${TARGET}"
              make installclean
            '''

            retry(2) {
              sh '''#!/bin/bash
                export CCACHE_DIR=$PWD/ccache
                export HOME=$WORKSPACE
                export USER=jenkins

                source build/envsetup.sh
                lunch "${TARGET}"
                make -j$(($(nproc)+1))
              '''
            }
          }

          stage 'Image Pinebook'
          if (params.BUILD_PINEBOOK) {
            sh '''#!/bin/bash
              source build/envsetup.sh
              lunch "${TARGET}"
              set -xe
              sdcard_image "${JOB_NAME}-pinebook-v${VERSION}-r${BUILD_NUMBER}.img.gz" pinebook
            '''
          }
        }

        withEnv([
          "VERSION=$VERSION",
          'TARGET=tulip_chiphd_atv-userdebug',
          'USE_CCACHE=true',
          'ANDROID_JACK_VM_ARGS=-Xmx3g -Dfile.encoding=UTF-8 -XX:+TieredCompilation',
          'ANDROID_NO_TEST_CHECK=true'
        ]) {
          stage 'TV'
          if (params.BUILD_TV) {
            sh '''#!/bin/bash
              export CCACHE_DIR=$PWD/ccache
              export HOME=$WORKSPACE
              export USER=jenkins

              source build/envsetup.sh
              lunch "${TARGET}"
              make installclean
            '''

            retry(2) {
              sh '''#!/bin/bash
                export CCACHE_DIR=$PWD/ccache
                export HOME=$WORKSPACE
                export USER=jenkins

                source build/envsetup.sh
                lunch "${TARGET}"
                make -j$(($(nproc)+1))
              '''
            }
          }

          stage 'Image TV'
          if (params.BUILD_TV) {
            sh '''#!/bin/bash
              source build/envsetup.sh
              lunch "${TARGET}"
              set -xe
              sdcard_image "${JOB_NAME}-tv-v${VERSION}-r${BUILD_NUMBER}.img.gz"
            '''
          }
        }

        withEnv([
          "VERSION=$VERSION",
          "CHANGES=$CHANGES",
          "PRERELEASE=$PRERELEASE",
          "GITHUB_USER=$GITHUB_USER",
          "GITHUB_REPO=$GITHUB_REPO"
        ]) {
          stage 'Release'
          sh '''#!/bin/bash
            set -xe
            shopt -s nullglob

            github-release release \
                --tag "${VERSION}" \
                --name "$VERSION: $BUILD_TAG" \
                --description "${CHANGES}\n\n${BUILD_URL}" \
                --draft

            github-release upload \
                --tag "${VERSION}" \
                --name "manifest.xml" \
                --file "manifest.xml"

            for file in *.gz; do
              github-release upload \
                  --tag "${VERSION}" \
                  --name "$(basename "$file")" \
                  --file "$file"
            done

            if [[ "$PRERELEASE" == "true" ]]; then
              github-release edit \
                --tag "${VERSION}" \
                --name "$VERSION: $BUILD_TAG" \
                --description "${CHANGES}\n\n${BUILD_URL}" \
                --pre-release
            else
              github-release edit \
                --tag "${VERSION}" \
                --name "$VERSION: $BUILD_TAG" \
                --description "${CHANGES}\n\n${BUILD_URL}"
            fi
          '''
        }
      }
    }
  }
}
