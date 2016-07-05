#!/bin/sh

#  ipa-build.sh
#  使用
#  把该文保存 ，修改权限chmod +x 你的shell文件名
#  把文件拖到 终端 。
#  参数
#  1，你要打包工程的根目录 2，你要输出的ipa文件目录（你当前用户要有权限） 3,指定的ipa 文件名  参数用空格隔开
#  eg:~
# ~/Desktop/ipa-build.sh  ~/Documents/workSpace/project   ~/Desktop/project   projectName

#!/bin/bash


#参数判断
if [ $# != 3 ] && [ $# != 2 ]&& [ $# != 1 ];then
echo "Number of params error! Need three params!"
echo "1.path of project(necessary) 2.path of ipa dictionary(necessary) 3.name of ipa file(necessary)1，你要打包工程的根目录 2，你要输出的ipa文件目录（你当前用户要有权限） 3,指定的ipa 文件名  参数用空格隔开"
exit

elif [ ! -d $1 ];then
echo "Params Error!! The 1 param must be a project root dictionary.你要打包工程的根目录"
exit
elif [ ! -d $2 ];then
echo "Params Error!! The 2 param must be a ipa dictionary.你要输出的ipa文件目录（你当前用户要有权限)解决方案： chomd 777 '指定路径'"
exit
fi

#工程绝对路径
cd $1
project_path=$(pwd)
#build文件夹路径
build_path=${project_path}/build


#工程配置文件路径
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')
project_infoplist_path=${project_path}/${project_name}/${project_name}-Info.plist
#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${project_infoplist_path})
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${project_infoplist_path})
#取bundle Identifier前缀
bundlePrefix=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" `find . -name "*-Info.plist"` | awk -F$ '{print $1}')




cd $project_path
#清理工程
xcodebuild clean || exit
#删除bulid目录
if  [ -d ${build_path} ];then
rm -rf ${build_path}
fi
#编译工程
xcodebuild  -configuration Release  -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${project_name} \
ONLY_ACTIVE_ARCH=NO \
TARGETED_DEVICE_FAMILY=1 \
DEPLOYMENT_LOCATION=YES CONFIGURATION_BUILD_DIR=${project_path}/build/Release-iphoneos  || exit



#IPA名称
if [ $# = 3 ];
then
ipa_name=$3
fi

if [ -d ./ipa-build ];then
rm -rf ipa-build
fi
#打包
cd $build_path
mkdir -p ipa-build/Payload
cp -r ./Release-iphoneos/*.app ./ipa-build/Payload/

cd ipa-build
zip -r ${ipa_name}.ipa *
cp -r ./${ipa_name}.ipa $2
rm -rf Payload
#删除bulid目录
if  [ -d ${build_path} ];then
rm -rf ${build_path}
fi