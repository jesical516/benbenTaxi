//
//  BMKVersion.h
//  BMapKit
//
//  Copyright 2011 Baidu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


/*****更新日志：*****
 V0.1.0： 测试版
 支持地图浏览，基础操作
 支持POI搜索
 支持路线搜索
 支持地理编码功能
 --------------------
 V1.0.0：正式发布版
 地图浏览，操作，多点触摸，动画
 标注，覆盖物
 POI、路线搜索
 地理编码、反地理编码
 定位图层
 --------------------
 V1.1.0：
 离线地图支持
 --------------------
 V1.1.1：
 增加suggestionSearch接口
 可以动态更改annotation title
 fix小内存泄露问题
 --------------------
 V1.2.1：
 增加busLineSearch接口
 修复定位圈范围内不能拖动地图的bug
 
 V2.0.0
 
 新增：
 全新的3D矢量地图渲染
    BMKMapView设定地图旋转俯视角度：rotation、overlooking 
    BMKMapView设定指南针显示位置：compassPositon        
    BMKMapView控制生命周期：viewWillAppear、viewWillDisappear
    地图标注可点，BMKMapViewDelegate新增接口回调接口onClickedMapPoi
    BMKAnnotationView设置annotation是否启用3D模式：enabled3D
 overlay绘制方式改变，采用opengl绘制：        
    BMKOverlayView使用opengl渲染接口：glRender子类重载此函数实现gl绘制
    基本opengl线绘制：renderLinesWithPoints        
    基本opengl面绘制：renderRegionWithPointsl 
 全新的矢量离线地图数据：        
    BMKOfflineMap下载离线地图：start        
    BMKOfflineMap更新离线地图：update        
    BMKOfflineMap暂停下载或更新：pasue        
    获得热点城市列表：getHotCityList        
    获得支持离线数据的城市：getOfflineCityList        
    根据城市名查询城市信息：searchCity  
 更新：
 BMKMapView的缩放级别zoomLevel更新为float型，实现无级缩放
 更新地图类型枚举：
 enum {   BMKMapTypeStandard  = 1,              ///< 标准地图      
          BMKMapTypeTrafficOn = 2,              ///< 实时路况   
          BMKMapTypeSatellite = 4,              ///< 卫星地图 
          BMKMapTypeTrafficAndSatellite = 8,    ///< 同时打开实时路况和卫星地图
 };

*********************/

/**
 *获取当前地图API的版本号
 *return  返回当前API的版本号
 */
UIKIT_STATIC_INLINE NSString* BMKGetMapApiVersion()
{
	return @"2.0.0";
}
