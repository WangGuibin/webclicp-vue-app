#!/bin/bash

git switch git-pages
git merge main
cp -r ./dist/* ./
rm -rf dist
git add .
git commit -m 'deploy pages'
git push origin --force git-pages
git switch main
rm -rf dist #打包打了个寂寞啊~
echo "已部署完毕,请访问: https://wangguibin.github.io/webclicp-vue-app/ 查看效果"