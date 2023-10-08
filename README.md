# HonkaiStarRailToonShader
  
![图片](https://github.com/Gaolingx/HonkaiStarRailToonShader/raw/main/Pictures/Final.PNG)
  
## What's This?
  
这是一个基于Unity引擎URP管线的仿制星穹铁道风格的卡通渲染项目。

## Installation & Usage
  
只需将/Shaders路径下解压对应版本的文件夹到你的Assets即可在材质球中看到添加的shader。
在开始之前，你至少需要准备如下的贴图，如果不知道如何获取他们，可以参考B站 @小二今天吃啥啊 的这个教程，[链接](https://www.bilibili.com/video/BV1t34y1H7jt/)
  
![图片](https://github.com/Gaolingx/HonkaiStarRailToonShader/raw/main/Pictures/MapUsed.PNG)  
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/raw/main/Pictures/v2-940ac11643928df7ad332a6f89369873_r.jpg)  
> (1)RGBA通道的身体BaseColor Map (2)RGBA通道的身体ILM Mask Map (3)身体ShadowCoolRamp  (4)身体ShadowWarmRamp (5)面部BaseColor Map (6)面部阴影SDF阈值图+ILM Mask Map(7)头发BaseColor Map (8)RGBA通道的头发ILM Mask Map (9)头发ShadowCoolRamp (10)头发ShadowWarmRamp
  
## Texture Import Setting
  
为什么我要特此说明这个问题？根据反馈，有的人在使用shader时候发现一些不正确的效果，这通常容易被认为是错误的代码导致的，真相是他们并没有使用正确的纹理导入设置，如下图，ramp阴影的交界处出现了我们不希望看到的锯齿而且看上去很奇怪。
  
![图片](https://github.com/Gaolingx/HonkaiStarRailToonShader/raw/main/Pictures/20230812_01.PNG)
  
1、除了表达颜色的贴图如Base Texture和Ramp Texture等颜色贴图以外，其他用于数值计算的贴图在Texture Import Settings中需要取消勾选sRGB，保证贴图在线性空间中。
  
![图片](https://github.com/Gaolingx/HonkaiStarRailToonShader/raw/main/Pictures/20230812_03.PNG)
  
2、鉴于Ramp贴图的特殊性，需要在导入设置中关闭“生成MipMap”，并将压缩改为“高质量”以获得更高精度。
  
![图片](https://github.com/Gaolingx/HonkaiStarRailToonShader/raw/main/Pictures/20230812_04.PNG)
  
完成上述设置后，效果终于正确了！Done Well!
  
![图片](https://github.com/Gaolingx/HonkaiStarRailToonShader/raw/main/Pictures/20230812_02.PNG)  
  
## *Important Information
  
此shader根据 bilibili@给你柠檬椰果养乐多你会跟我玩吗 大佬教程制作的《崩坏：星穹铁道》的卡通着色器（ToonShader）,非常感谢这位大佬的教程，并在此基础上个人增加了些有趣的功能，如增加了keyword提高性能，支持自定义描边颜色（基于材质），曝光控制等，仅适用于Unity的URP管线，为了使深度边缘光正常工作，请在Univer Render Pipeline Asset中开启 Depth Texture，如果要用于其他游戏或者MMD记得自己给lightmap.a通道赋个值，ramp图可以用ps画也可以用文件夹附带的工具，切记在ramp贴图的导入设置中关闭“Generate Mipmaps"避免渲染错误。  
  
下一步计划研究shader部分怎么加入tonemapping和平滑法线，再加一套程序化的lightmap+ramp纹理生成插件拓展该着色器的泛用性，有兴趣可以考虑follow，请自觉遵守开源协议，测试模型版权归MiHoYo所有，祝君使用愉快，如果觉得不错可以给个star，有任何想法和建议欢迎提issue或提pr。
  
Enjoy Yourself！

## Links
  
欲了解更多作者相关信息欢迎访问：
[米游社@爱莉小跟班gaolx](https://www.miyoushe.com/dby/accountCenter/postList?id=277273444)、[Bilibili@galing2333](https://space.bilibili.com/457123942?spm_id_from=..0.0)