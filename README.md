# SOFTWARE DESIGN'S FINAL PROJECT

System supports many popular deep learning frameworks: Tensorflow, Pytorch, Darknet, ...

Main function: helps users to run a model that has been uploaded to the system with the input of an image obtained from a mobile application.

## Usecase Diagram:
![usecase](https://scontent.fdad3-3.fna.fbcdn.net/v/t1.15752-9/119905121_987828635070741_3007317934651593569_n.png?_nc_cat=108&_nc_sid=b96e70&_nc_ohc=GxuJ_cKJHsMAX-CGqcd&_nc_oc=AQlQTe6X5qkxSBca5wlChyhFh12GFSFMVR7nA3NvBJ0Jstvv_vuKRMW5ZLrvRFLKU_CCCuJd6aKC-EPTTL6P8_8F&_nc_ht=scontent.fdad3-3.fna&oh=d11b301526397010d3316a44da5516ed&oe=5F92338C "Usecase Diagram")

## Mobile part:
![Mobile](https://github.com/HDCong/final_tkpm/blob/master/resource/mobile.gif)
### Technologies used:
#### BLoC Pattern
Organize code and divide business logic with UI.
Using BLoC, solving the problem of having to rebuild the entire widget tree by listening to the component that has a change in runtime (event) will be handled by BLoC, then returning the stream, corresponding to This stream is handled to rebuild this component to serve the display of the changes of the component while minimizing rebuilding the Widget tree.
![BLoC](https://miro.medium.com/max/1400/1*P8CgLEsuO4LygZjXdHuOqQ.png)
##### BLoC 
![Mechanism](https://scontent.fdad3-1.fna.fbcdn.net/v/t1.15752-9/120136373_1689986121176631_9007201684168122963_n.png?_nc_cat=106&_nc_sid=b96e70&_nc_ohc=0XNW5UtMOmwAX8STAib&_nc_ht=scontent.fdad3-1.fna&oh=5ead1f3a90d778e35163569f6025f165&oe=5F90AA7A)
• Data input will go to the sink (such as in TextField, when the user changes text, we have an onChanged event, which will add the TextField data to the corresponding sink)
• Event will also be passed to BLoC via sink.
• The output will be given at the stream. At the same time, BLoC will notifychange to the widgets also through the stream to rebuild that widget 
#### Repository Pattern
The middle layer between Business Logic and Data Access
Do not call API Server directly, but call through UserRepository.
#### Dependency Injection

## Web part:
![Web](https://github.com/HDCong/final_tkpm/blob/master/resource/webpart.gif)
