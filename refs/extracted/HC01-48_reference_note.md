# HC01-48 直流减速电机资料记录

## 来源

- 网页标题：Biaxial DC Gear Motor Smart Car Robot Plastic Tire Wheel Gear Rate 1:48
- 来源链接：https://www.evselectro.com/biaxial-dc-gear-motor-smart-car-robot-plastic-tire-wheel-gear-rate-1%3A48-4369
- 本地保存：`refs/extracted/HC01-48_EVSElectro_page.html`

该页面是经销商产品参数页，不是原厂 datasheet。用于课程设计前期资料收集时，应标注为“参考参数”，最终实物调试仍以课程套件电机铭牌、实验箱说明或实测数据为准。

## 可引用参数

| 项目 | 参数 |
| --- | --- |
| 型号 | HC01-48 |
| 类型 | 双轴直流减速电机 |
| 工作电压 | 3-6 V |
| 减速比 | 1:48 |
| 带轮空载转速 | 约 22 rpm @ 3 V；约 44 rpm @ 5 V |
| 扭矩 | 约 0.8 kg.cm |
| 轮径 | 约 65 mm |
| 轮胎厚度 | 约 28 mm |
| 电机重量 | 约 28 g |
| 轮胎重量 | 约 34 g |

## 在课题 3 中的使用

HC01-48 作为智能小车左右轮动力来源，由 L293D 进行方向控制。程序中只输出前进、后退、右转、停止等方向控制信号，不直接闭环控制转速。若实物电机启动电流超过 L293D 单通道能力，应改用更大电流的电机驱动模块，或降低负载后再进行调试。
