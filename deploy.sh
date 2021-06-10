#!/bin/bash

git checkout git-pages
git merge --strategy=theirs main
cp -r ./dist/* ./
rm -rf dist
git add .
git commit -m 'deploy pages'
git push origin --force git-pages
git checkout main
rm -rf dist #打包打了个寂寞啊~

echo "\t\t\t\t\t\t\t\t\t\t"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "************************************************************************"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "\t\t\t\t\t\t\t\t\t\t"

echo "已部署完毕,请访问: https://wangguibin.github.io/webclicp-vue-app/ 查看效果"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "************************************************************************"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "\t\t\t\t\t\t\t\t\t\t"
echo "\t\t\t\t\t\t\t\t\t\t"
