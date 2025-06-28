<template>
  <div id="app">
    <h2 class="main-title">WebClip配置在线生成工具</h2>
    <div class="tip">(建议使用Safari手机自带的浏览器打开体验更佳哦~)</div>
    <h6>功能介绍:</h6>
    <ol>
      <li>选择web类型就类似桌面书签</li>
      <li>选择app类型即类似于新增一个app入口和图标副本</li>
    </ol>
    <el-form :model="formData">
      <el-form-item label="应用类型: " label-width="100px">
        <el-radio-group v-model="formData.type">
          <el-radio label="web"></el-radio>
          <el-radio label="app"></el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="桌面显示名称: " label-width="100px">
        <el-input v-model="formData.appName" placeholder="请输入名称"></el-input>
      </el-form-item>
      <el-form-item
        :label="formData.type === 'web' ? 'URL地址: ' : 'Universal Link 或者 URL Scheme : '"
      >
        <el-input
          v-model="formData.URL"
          type="url"
          placeholder="请输入link或者scheme"
        ></el-input>
      </el-form-item>
      <div v-if="formData.type === 'app'" class="app-tip">
        <p>
          苹果App的这个
          <a href="https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html#//apple_ref/doc/uid/TP40016308-CH12-SW1" target="_blank">
            universal link
          </a>
          URL地址具体如何获取尚未可知,只能是自己已知的去验证或者主流的App
          例如微信(
          <a href="https://www.wechat.com" target="_blank">https://www.wechat.com</a>
          ) , 淘宝(
          <a href="https://b.mashort.cn" target="_blank">https://b.mashort.cn</a>
          )
          <span> ~~~~~~ </span>
          <a href="https://search.developer.apple.com/appsearch-validation-tool/" target="_blank">
            苹果universal link验证入口
          </a>
        </p>
      </div>
      <el-form-item
        v-if="formData.type === 'app'"
        label="bundleId: "
        label-width="100px"
      >
        <el-input v-model="formData.bundleId" placeholder="请输入bundleId"></el-input>
      </el-form-item>
      <el-form-item label="图标(可选): " label-width="120px">
        <input
          type="file"
          accept="image/*"
          @change="selectImageAction"
        />
        <img
          v-if="imagePath"
          :src="imagePath"
          alt="图标"
          class="icon-preview"
        />
      </el-form-item>
      <el-form-item label="能否从桌面删除: ">
        <el-switch v-model="formData.canDeleteDesktop"></el-switch>
      </el-form-item>
      <el-form-item>
        <el-button
          class="button-style"
          type="primary"
          round
          :loading="loading"
          @click="onSubmit"
          size="medium"
        >生成配置</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
export default {
  name: "App",
  data() {
    return {
      loading: false,
      imagePath: "",
      base64Icon: "",
      formData: {
        type: "web",
        appName: "",
        URL: "",
        bundleId: "",
        appId: this.getUUID(),
        canDeleteDesktop: true,
      },
    };
  },
  methods: {
    getUUID() {
      // 推荐使用 crypto.randomUUID()，更安全
      if (window.crypto && window.crypto.randomUUID) {
        return window.crypto.randomUUID().toUpperCase();
      }
      return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
        var r = (Math.random() * 16) | 0,
          v = c == "x" ? r : (r & 0x3) | 0x8;
        return v.toString(16).toUpperCase();
      });
    },
    getObjectURL(file) {
      return (window.URL || window.webkitURL).createObjectURL(file);
    },
    selectImageAction(e) {
      const file = e.target.files[0];
      if (!file) return;
      if (!file.type.startsWith("image/")) {
        this.$message.error("请选择图片文件！");
        return;
      }
      this.imagePath = this.getObjectURL(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        this.base64Icon = reader.result;
      };
      reader.readAsDataURL(file);
    },
    onSubmit() {
      if (!this.formData.appName.trim()) {
        this.$message.error("请输入应用名称(web/app的名字),再提交生成配置~");
        return;
      }
      if (!this.formData.URL.trim()) {
        this.$message.error("请输入URL网址,再提交生成配置~");
        return;
      }
      if (this.formData.type === "app" && !this.formData.bundleId.trim()) {
        this.$message.error("请输入应用bundleId,再提交生成配置~");
        return;
      }
      if (this.formData.type === "web") {
        this.formData.bundleId = "";
      }
      this.loading = true;
      this.createXML();
    },
    createXML() {
      const base64Str = this.base64Icon.replace(/^data:image\/\w+;base64,/, "");
      const iconXML = base64Str
        ? `<key>Icon</key>\n<data>${base64Str}</data>`
        : "";
      const URL = `<key>URL</key>\n<string>${this.formData.URL}</string>`;
      const bundleId = this.formData.bundleId
        ? `<key>TargetApplicationBundleIdentifier</key>\n<string>${this.formData.bundleId}</string>`
        : "";
      const xmlText = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>FullScreen</key>
      <true/>
      ${iconXML}
      <key>IgnoreManifestScope</key>
      <true/>
      <key>IsRemovable</key>
      <${this.formData.canDeleteDesktop}/>
      <key>Label</key>
      <string>${this.formData.appName}</string>
      <key>PayloadDescription</key>
      <string>${this.formData.appName}WebClip配置</string>
      <key>PayloadDisplayName</key>
      <string>Web Clip</string>
      <key>PayloadIdentifier</key>
      <string>com.apple.webClip.managed.${this.formData.appId}</string>
      <key>PayloadType</key>
      <string>com.apple.webClip.managed</string>
      <key>PayloadUUID</key>
      <string>${this.formData.appId}</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
      <key>Precomposed</key>
      <true/>
      ${URL}
      ${bundleId}
    </dict>
  </array>
  <key>PayloadDisplayName</key>
  <string>${this.formData.appName}的描述文件</string>
  <key>PayloadIdentifier</key>
  <string>CoderWGBDeMacBook-Pro.${this.getUUID()}</string>
  <key>PayloadRemovalDisallowed</key>
  <false/>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadUUID</key>
  <string>${this.getUUID()}</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
</plist>
`;

      const base64 = "data:application/x-apple-aspen-config;base64," + btoa(unescape(encodeURIComponent(xmlText)));
      window.location.href = base64;
      this.loading = false;
      setTimeout(() => {
        window.location.href = "shortcuts://x-callback-url/run-shortcut?x-error=App-prefs:root=General&path=ManagedConfigurationList/PurgatoryInstallRequested";
      }, 3000);
    },
  }
};
</script>

<style>
#app {
  margin: 20px;
  padding: 15px;
  width: 300px;
}
.main-title {
  margin-bottom: 40px;
}
.tip {
  color: red;
}
.button-style {
  width: 300px;
  height: 50px;
  font-size: 20px;
  font-weight: 800;
}
.icon-preview {
  display: block;
  margin-top: 10px;
  width: 100px;
  height: 100px;
}
.app-tip {
  font-size: 13px;
  color: #666;
  margin-bottom: 12px;
}
</style>
