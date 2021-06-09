<template>
  <div id="app">
    <div style="color: red">
      (建议使用Safari手机自带的浏览器打开体验更佳哦~)
    </div>
    <h2 style="margin-bottom: 40px">WebClip配置在线生成工具</h2>
    <el-form :model="formData">
      <el-form-item label="应用类型: " label-width="100px">
        <el-radio-group v-model="formData.type">
          <el-radio label="web"></el-radio>
          <el-radio label="app"></el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="桌面显示名称: " label-width="100px">
        <el-input
          v-model="formData.appName"
          placeholder="请输入名称"
        ></el-input>
      </el-form-item>

      <el-form-item
        v-if="formData.type === 'web'"
        label="URL地址: "
        label-width="100px"
      >
        <el-input
          v-model="formData.URL"
          type="url"
          placeholder="请输入URL地址"
        ></el-input>
      </el-form-item>

      <el-form-item
        v-if="formData.type === 'app'"
        label="bundleId: "
        label-width="100px"
      >
        <el-input
          v-model="formData.bundleId"
          placeholder="请输入bundleId"
        ></el-input>
      </el-form-item>

      <el-form-item label="图标(可选): " label-width="120px">
        <input
          type="file"
          accept="image/*"
          label="选择图片"
          @change="selectImageAction"
        />
        <img
          v-show="imagePath.length"
          :src="imagePath"
          alt="图标"
          width="100px"
          height="100px"
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
          >生成配置</el-button
        >
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
      formData: {
        type: "web",
        appName: "",
        URL: "",
        bundleId: "",
        appId: this.getUUID(),
        canDeleteDesktop: true,
        base64Icon: "",
      },
    };
  },
  computed: {
    appIcon() {
      return this.formData.base64Icon.replace(/^data:image\/\w+;base64,/, "");
    },
  },
  methods: {
    getUUID() {
      return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(
        /[xy]/g,
        function (c) {
          var r = (Math.random() * 16) | 0,
            v = c == "x" ? r : (r & 0x3) | 0x8;
          return v.toString(16).toUpperCase();
        }
      );
    },
    //获取文件路径
    getObjectURL(file) {
      var url = null;
      if (window.createObjectURL != undefined) {
        // basic
        url = window.createObjectURL(file);
      } else if (window.URL != undefined) {
        // mozilla(firefox)
        url = window.URL.createObjectURL(file);
      } else if (window.webkitURL != undefined) {
        // webkit or chrome
        url = window.webkitURL.createObjectURL(file);
      }
      return url;
    },
    selectImageAction(e) {
      var file = e.target.files[0];
      this.imagePath = this.getObjectURL(file);
      var reader = new FileReader();
      if (file) {
        //通过文件流将文件转换成Base64字符串
        reader.readAsDataURL(file);
        reader.onloadend = function () {
          this.formData.base64Icon = reader.result;
        };
      }
    },
    onSubmit() {
      if (this.formData.appName.length === 0) {
        this.$message.error("请输入应用名称(web/app的名字),再提交生成配置~");
        return;
      }
      if (this.formData.type === "web" && this.formData.URL.length === 0) {
        this.$message.error("请输入URL网址,再提交生成配置~");
        return;
      }
      if (this.formData.type === "app" && this.formData.bundleId.length === 0) {
        this.$message.error("请输入应用bundleId,再提交生成配置~");
        return;
      }
      this.loading = true;
      this.createXML();
    },
    createXML() {
      var icon = this.appIcon.length
        ? `<key>Icon</key>
			<data>${this.appIcon}</data>`
        : "";
      // URL是必填的 app的时候可以任意 因为跳转只是根据bundleId
      var URL = `<key>URL</key>
			<string>${
        this.formData.URL.length ? this.formData.URL : "https://example.com"
      }</string>`;
      var bundleId = this.formData.bundleId.length
        ? `<key>TargetApplicationBundleIdentifier</key>
          <string>${this.formData.bundleId}</string>`
        : "";
      var xmlText = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>FullScreen</key>
			<true/>
			${icon}
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

      this.saveFile(`${this.formData.appName}.mobileconfig`, xmlText);
      this.loading = false;
    },
    //模拟点击
    fake_click(obj) {
      var ev = document.createEvent("MouseEvents");
      ev.initMouseEvent(
        "click",
        true,
        false,
        window,
        0,
        0,
        0,
        0,
        0,
        false,
        false,
        false,
        false,
        0,
        null
      );
      obj.dispatchEvent(ev);
    },
    //保存文件
    /*这里保存到手机沙盒 通过自带的文件.app打开一样可以安装描述文件 再就是这里最流畅的做法是上传至文件服务器
    然后用Safari打开这个文件链接是最为完美的 ~!*/
    saveFile(name, data) {
      var urlObject = window.URL || window.webkitURL || window;

      var downloadData = new Blob([data]);

      var save_link = document.createElementNS(
        "http://www.w3.org/1999/xhtml",
        "a"
      );
      save_link.href = urlObject.createObjectURL(downloadData);
      save_link.download = name;
      this.fake_click(save_link);
    },
  },
};
</script>

<style>
#app {
  margin: 20px;
  padding: 15px;
  width: 300px;
}
.button-style {
  width: 300px;
  height: 50px;
  font-size: 20px;
  font-weight: 800px;
}
</style>
