<template>
  <div id="app">
    <h2 style="margin-bottom: 40px">WebClip配置在线生成工具</h2>
    <div style="color: red">
      (建议使用Safari手机自带的浏览器打开体验更佳哦~)
    </div>
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
        <el-input
          v-model="formData.appName"
          placeholder="请输入名称"
        ></el-input>
      </el-form-item>

      <el-form-item
        :label="
          this.formData.type === 'web'
            ? 'URL地址: '
            : 'Universal Link 或者 URL Scheme : '
        "
      >
        <el-input
          v-model="formData.URL"
          type="url"
          placeholder="请输入link或者scheme"
        ></el-input>
      </el-form-item>
      <div v-if="this.formData.type === 'app'">
        <p>
          苹果App的这个<a
            href="https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html#//apple_ref/doc/uid/TP40016308-CH12-SW1"
            target="_blank"
          >
            universal link</a
          >
          URL地址具体如何获取尚未可知,只能是自己已知的去验证或者主流的App
          例如微信(<a href="https://www.wechat.com" target="_blank"
            >https://www.wechat.com</a
          >) , 淘宝(<a href="https://b.mashort.cn" target="_blank"
            >https://b.mashort.cn</a
          >) <span> ~~~~~~ </span>
          <a
            href="https://search.developer.apple.com/appsearch-validation-tool/"
            target="_blank"
          >
            苹果universal link验证入口
          </a>
        </p>
      </div>
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
      var _this = this;
      var file = e.target.files[0];
      this.imagePath = this.getObjectURL(file);
      var reader = new FileReader();
      if (file) {
        //通过文件流将文件转换成Base64字符串
        reader.readAsDataURL(file);
        reader.onloadend = function () {
          // console.log(reader.result);
          _this.base64Icon = reader.result;
        };
      }
    },
    onSubmit() {
      if (this.formData.appName.length === 0) {
        this.$message.error("请输入应用名称(web/app的名字),再提交生成配置~");
        return;
      }
      if (this.formData.URL.length === 0) {
        this.$message.error("请输入URL网址,再提交生成配置~");
        return;
      }

      if (this.formData.type === "app" && this.formData.bundleId.length === 0) {
        this.$message.error("请输入应用bundleId,再提交生成配置~");
        return;
      }

      if (this.formData.type === "web" && this.formData.URL.length !== 0) {
        this.formData.bundleId = "";
      }
      this.loading = true;
      this.createXML();
    },
    createXML() {
      var base64Str = this.base64Icon.replace(/^data:image\/\w+;base64,/, "");
      var iconXML =
        base64Str && base64Str.length
          ? `<key>Icon</key>
			<data>${base64Str}</data>`
          : "";
      // URL是必填的
      var URL = `<key>URL</key>
			<string>${
        this.formData.URL.length ? this.formData.URL : "https://foo.example.com"
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

      this.saveConfigFile(
        xmlText,
        "text/xml",
        `${this.formData.appName}.mobileconfig`
      );
      this.loading = false;
    },

    saveConfigFile(textValue, fileType, fileName) {
      var blob;
      if (typeof window.Blob == "function") {
        blob = new Blob([textValue], {
          type: fileType,
        });
      } else {
        var BlobBuilder =
          window.BlobBuilder ||
          window.MozBlobBuilder ||
          window.WebKitBlobBuilder ||
          window.MSBlobBuilder;
        var bb = new BlobBuilder();
        bb.append(textValue);
        blob = bb.getBlob(fileType);
      }
      var URL = window.URL || window.webkitURL;
      var blobUrl = URL.createObjectURL(blob);
      var archorDom = document.createElement("a");
      if ("download" in archorDom) {
        archorDom.style.visibility = "hidden";
        archorDom.href = blobUrl;
        archorDom.download = fileName;
        document.body.appendChild(archorDom);
        var evt = document.createEvent("MouseEvents");
        evt.initEvent("click", true, true);
        archorDom.dispatchEvent(evt);
        document.body.removeChild(archorDom);
      } else if (navigator.msSaveBlob) {
        navigator.msSaveBlob(blob, fileName);
      } else {
        location.href = blobUrl;
      }
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
