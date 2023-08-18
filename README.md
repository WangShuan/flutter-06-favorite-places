# 使用 flutter 建構 Favorite Places APP

筆記連結：<https://hackmd.io/qi4A57mdT6yFOw-IFmdqgA?view>

學習如何使用設備本身的功能（相機、相簿、定位當前位置）、如何使用 Google Map 在應用程式中顯示地圖與標記位置、如何將數據保存在設備中。

## 會用到的 pub 介紹

* `flutter_riverpod`: 用於狀態管理
* `uuid`: 用來產生隨機 `id`
* `image_picker`: 拍攝照片或從相簿選取圖片並取得檔案來使用
* `location`: 獲取當前位置經、緯度來使用
* `flutter_config`: 用來在專案中存取 `.env` 檔案
* `http`: 與 Google API 進行交互，以獲取經、緯度所對應的地址資訊
* `google_maps_flutter`: 在應用程式中顯示 Google Map
* `path_provider`: 用於查找文件系統上的常用位置以保存數據
* `path`: 用來簡化操作路徑的方法
* `sqflite`: 使用 `SQL` 命令在設備上存儲數據

## 建立雛型

先建立 `models/place.dart` 設置地點的藍圖：

```dart
import 'dart:io';

import 'package:uuid/uuid.dart'; // 引入 uuid

class PlaceLocation { // 設置位置資訊要用的藍圖
  final double lat; // 保存經度
  final double lng; // 保存緯度
  final String? address; // 保存地址資訊

  const PlaceLocation({
    required this.lat,
    required this.lng,
    this.address,
  });
}

class Place { // 設置地點的藍圖
  final String id; // 要有 id
  final String title; // 標題
  final File image; // 圖片
  final PlaceLocation location; // 位置資訊

 // Place 的 id 用 uuid 生成預設值
 Place(this.title, this.image, this.location) : id = const Uuid().v4();
}
```

## 畫面分析

* 首頁畫面：用列表形式顯示所有地點，主要放置圖片縮圖、標題與地址資訊。
  * 可通過 `ListView.builder` 建立
* 地點詳細介紹畫面：將圖片設為滿版背景，顯示標題與地址資訊在畫面下方、放置地圖縮圖點擊後開啟地圖畫面。
  * 使用 `Stack` 建立滿版背景圖再搭配 `Positioned` 放置文字資訊在 bottom 的位置
  * 地圖縮圖用 `CircleAvatar` 製作（可設置 `radius` 調整圓的大小），父層可使用 `GestureDetector` 以綁定點擊事件
* 新增地點畫面：顯示標題欄位、拍攝或選取圖片並預覽、定位或選取地點並預覽、提交按鈕。
  * 可用 `Form` 小部件處理標題欄位，也可直接用 `TextField` 小部件
  * 通過 `await ImagePicker().pickImage(source: ImageSource.gallery)` 從相簿選取圖片檔案
  * 通過 `await ImagePicker().pickImage(source: ImageSource.camera)` 開啟相機拍攝照片
  * 通過 `await location.getLocation()` 獲取當前定位
  * 使用 Google 提供的 API `https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey` 可獲取地址資訊
  * 使用 Google 提供的網址 `https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&scale=2&zoom=15&size=400x300&key=$apiKey&markers=color:red%7Clabel:%7C$lat%2C$long` 可顯示地圖截圖
* 地圖畫面：顯示地圖、在定位的位置上顯示 Marker 。
  * 通過 `GoogleMap` 小部件，傳入 `initialCameraPosition` 即可顯示經、緯度座標位於正中央的 Google 地圖畫面
  * 於 `GoogleMap` 小部件，傳入 `markers` 即可在畫面中顯示 Marker
  * 於 `GoogleMap` 小部件，設置 `onTap` 事件即可保存選中位置的座標

## 主要程式碼片段

### 地點詳細介紹畫面

檔案路徑： `lib/screens/place_screen.dart`

```dart
Scaffold(
  extendBodyBehindAppBar: true, // 設置背景延伸到 AppBar 下方
  appBar: AppBar(
    backgroundColor: Colors.transparent, // 讓 AppBar 背景色為透明
  ),
  body: Stack( // 使用 Stack 小部件，讓子部件產生交疊
    children: [
      Hero( // 通過 Hero 設置屏幕之間圖片的過場效果
        tag: place.id,
        child: Image.file(
          place.image,
          fit: BoxFit.cover, // 設置圖片 cover 填滿大小
          width: double.infinity, // 設置為最大寬度填滿畫面
          height: double.infinity, // 設置為最大高度填滿畫面
        ),
      ),
      Positioned( // 使用 Positioned 小部件，讓子部件放在絕對定位上
        bottom: 0, // 設置定位在最底部
        left: 0, right: 0, // 同時設置 left: 0, right: 0 可讓該部件填滿父層寬度
        child: Container( // 利用 Container 做出漸層色背景顯示資訊
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            children: [
              GestureDetector( // 利用 GestureDetector 小部件綁定點擊事件
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  fullscreenDialog: true, // 顯示由下往上滑的畫面，且原本的返回箭頭會變為關閉按鈕
                  builder: (context) => MapScreen(
                    isSelecting: false,
                    initLocation: PlaceLocation(lat: place.location.lat, lng: place.location.lng, address: place.location.address),
                  ),
                )),
                child: CircleAvatar( // 用 CircleAvatar 做出原型地圖縮圖
                  radius: 80, // 設置圓形大小
                  backgroundImage: NetworkImage(
                      'https://maps.googleapis.com/maps/api/staticmap?center=${place.location.lat},${place.location.lng}&scale=2&zoom=15&size=400x300&key=$googleApiKey&markers=color:red%7Clabel:%7C${place.location.lat}%2C${place.location.lng}'),
                ),
              ),
              Text( // 顯示標題
                place.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
              ),
              Text( // 顯示地址資訊
                place.location.address!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.secondary, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      )
    ],
  ),
);
```

### 圖片選取及預覽區塊

這邊將新增地點中的『圖片選取及預覽』區塊，獨立拉出來做一個客製化小部件 `ImgaeInput` ：

```dart
class ImageInput extends StatefulWidget {
  const ImageInput(this.selectedImg, {super.key});
  // 這邊設定一個 selectedImg 是從父層傳入的函數，用來將 File img 傳給父層使用
  final void Function(File img) selectedImg;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImg; // 宣告一個變數用來存放選中的圖片檔案
  @override
  Widget build(BuildContext context) {
    return Container( // 用 Container 做一個帶邊框與背景色的區塊
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.3),
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack( // 通過 Stack 讓子部件互相交疊
        alignment: Alignment.bottomCenter, // 設置對齊方式為下方的正中央
        children: [
          if (_selectedImg != null) // 判斷使否有選中的圖片
            ClipRRect( // 用 ClipRRect 小部件做圓角矩形
              borderRadius: BorderRadius.circular(16),
              child: Image.file( // 顯示圖片檔案
                _selectedImg!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: colorScheme.primary.withOpacity(0.7)),
                onPressed: () async { // 點擊開啟相機
                  // ImageSource.camera 表示拍攝照片、maxWidth 用來設置圖片最大寬度
                  final img = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 600);
                  if (img == null) {
                    return;
                  }
                  setState(() { // 將拍攝的照片路徑傳給 File 小部件做成 File 並保存到 _selectedImg 中
                    _selectedImg = File(img.path);
                  });
                  widget.selectedImg(_selectedImg!); // 呼叫父層傳來的 selectedImg 把拍攝的照片傳出去父層做使用
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('拍攝照片'),
              ),
              Text(
                '或',
                style: TextStyle(color: colorScheme.primary),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: colorScheme.primary.withOpacity(0.7)),
                onPressed: () async {
                  // ImageSource.gallery 表示從照片庫中選擇檔案、maxWidth 用來設置圖片最大寬度
                  final img = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600);
                  if (img == null) {
                    return;
                  }
                  setState(() { // 將選中的圖片路徑傳給 File 小部件做成 File 並保存到 _selectedImg 中
                    _selectedImg = File(img.path);
                  });
                  widget.selectedImg(_selectedImg!); // 呼叫父層傳來的 selectedImg 把選中的圖片傳出去父層做使用
                },
                icon: const Icon(Icons.image_rounded),
                label: const Text('從相簿中選擇'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
```

>由於目前版本的 `image_picker` 無法在 IOS 模擬器中開啟相機，如需使用相機功能，需要使用真實 iPhone 設備。
>可通過 iPhone 充電線連接電腦，並將手機的『開發者模式』打開(設定>安全性>開法者模式，開啟會要求重新啟動手機)，再用 VS Code 選擇自己的 iPhone 啟動 flutter 即可測試應用程式。

### 定位或選取地點及預覽區塊

首先將 Google API Key 設為 `.env` ：

1. 安裝 `flutter_config` ：

```shell
flutter pub add flutter_config
```

2. `main.dart` 中初始化：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

3. 建立環境變量檔案 `.env` ：

```env
GOOGLE_API_KEY=AAAaaaBBBbbbCCCcccDDDdddEEEeeeFFFfffGGG
```

4. 於需要使用的地方獲取環境變量：

```dart
final googleApiKey = FlutterConfig.get('GOOGLE_API_KEY');
```

接著將獲取經、緯度以及利用經、緯度取得地址資訊的函數抽出來，做成 `location_provider.dart` 中的方法以方便取用：

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:flutter_config/flutter_config.dart';

final googleApiKey = FlutterConfig.get('GOOGLE_API_KEY'); // 獲取 env

class LocationNotifier extends StateNotifier {
  LocationNotifier() : super(''); // 設置初始值

  // 設置獲取當前位置的方法
  Future<LocationData> getUserLocation() async {
    Location location = Location();
    
    // 判斷是否有取得定位的權限
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception('無法取得當前位置。');
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception('無法取得當前位置。');
        }
      }

      // 獲取當前所在位置
      locationData = await location.getLocation();
    } catch (err) {
      throw Exception('無法取得當前位置。');
    }
    
    // 回傳當前所在位置
    return locationData;
  }

  // 設置獲取地址資訊的方法
  Future<String> getAddress(double lat, double long) async {
    // 發送 get 請求
    final res = await http.get(
      Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        "latlng": "$lat,$long", // 傳入經緯度
        "key": googleApiKey, // 傳入 apiKey
        "language": "zh-TW", // 設置語言
      }),
    );
    // 回傳地址資訊
    return json.decode(res.body)['results'][0]['formatted_address'];
  }
}

final locationProvider = StateNotifierProvider(
  (ref) {
    return LocationNotifier();
  },
);
```

最後把新增地點畫面中的『定位/選取地點及預覽』區塊，獨立拉出來做一個客製化小部件 `LocationInput` ：

```dart
// 把有狀態小部件改為 ConsumerStatefulWidget 小部件，以使用 provider
class LocationInput extends ConsumerStatefulWidget {
  const LocationInput(this.setLocation, {super.key});
  // 從父層獲取 setLocation 函數用來保存地址資訊並傳給父層使用
  final void Function(double lat, double long, String address) setLocation;

  @override
  ConsumerState<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends ConsumerState<LocationInput> {
  // 獲取 env 用於顯示地圖截圖
  final googleApiKey = FlutterConfig.get('GOOGLE_API_KEY');
  // 宣告參數用來存放地圖截圖網址
  String? img;

  // 獲取用戶當前位置
  Future<void> _getUserLocation() async {
    LocationData locaData;
    try {
      locaData = await ref.read(locationProvider.notifier).getUserLocation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('無法取得當前位置。')));
      return;
    }

    final lat = locaData.latitude;
    final long = locaData.longitude;

    if (lat == null || long == null) return;

    _setAddressAndShowImg(lat, long);
  }

  // 獲取用戶於地圖中選擇的位置
  Future<void> _selectOnMap() async {
    LatLng locaData;
    try {
      // 開啟地圖畫面並接收回傳的經緯度
      locaData = await Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const MapScreen(
          isSelecting: true,
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('無法取得位置資訊。')));
      return;
    }

    _setAddressAndShowImg(locaData.latitude, locaData.longitude);
  }

  // 用來獲取地址資訊及設置地圖截圖
  void _setAddressAndShowImg(lat, long) async {
    final address = await ref.read(locationProvider.notifier).getAddress(lat, long);

    setState(() {
      img = 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&scale=2&zoom=15&size=400x300&key=$googleApiKey&markers=color:red%7Clabel:%7C$lat%2C$long';
    });

    widget.setLocation(lat, long, address); // 呼叫父層函數以保存地址資訊
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.3),
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (img != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/location-placeholder.gif',
                image: img!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                style: buttonStyle,
                onPressed: _getUserLocation,
                icon: const Icon(Icons.my_location_outlined),
                label: const Text('我的位置'),
              ),
              Text(
                '或',
                style: TextStyle(color: colorScheme.primary),
              ),
              FilledButton.icon(
                style: buttonStyle,
                onPressed: _selectOnMap,
                icon: const Icon(Icons.map_rounded),
                label: const Text('從地圖中選擇'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
```

### 新增地點畫面

這邊主要分享 `Form` 小部件內容：

```dart
Form(
  key: formKey,
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        TextFormField( // 用 TextFormField 處理地點名稱的驗證與提交
          decoration: const InputDecoration(
            labelText: '地點名稱',
            contentPadding: EdgeInsets.zero,
          ),
          maxLength: 8,
          validator: (val) => val == null || val.isEmpty || val.trim().length < 2 ? 'Name must be at least 2 characters.' : null,
          onSaved: (newValue) => name = newValue!,
        ),
        const SizedBox(height: 16),
        // 使用自定義小部件 ImageInput 並將選中的圖片檔案設為 image ，於提交表單時才可傳到 Plcae 中
        ImageInput((img) => image = img),
        const SizedBox(height: 16),
        // 使用自定義小部件 LocationInput 並將選中的地點資訊設為 PlaceLocation ，於提交表單時才可傳到 Plcae 中
        LocationInput((lat, long, address) => local = PlaceLocation(lat: lat, lng: long, address: address)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: submitForm,
            child: const Text('Submit'),
          ),
        )
      ],
    ),
  ),
)
```

### 地圖畫面

```dart
class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.initLocation = const PlaceLocation(
      lat: 25.10235351700014,
      lng: 121.54849200004878,
    ),
    this.isSelecting = true,
  });
  final bool isSelecting; // 設置參數用來判斷是否要選取地點
  final PlaceLocation initLocation; // 設定預設的經緯度位置

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _markerLocation; // 用來存放選中的地點

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? '請選擇地點' : widget.initLocation.address!),
        actions: [
          if (widget.isSelecting) // 如果是選地點的模式就顯示按鈕
            IconButton( // 放置一個保存按鈕，將選中的地點傳回新增地點畫面
              onPressed: () => Navigator.of(context).pop(_markerLocation),
              icon: const Icon(Icons.save_rounded),
            )
        ],
      ),
      body: GoogleMap( // 顯示 GoogleMap
        initialCameraPosition: CameraPosition( // 設置初始經緯度
          target: LatLng(
            widget.initLocation.lat,
            widget.initLocation.lng,
          ),
          zoom: 16, // 設定縮放等級
        ),
        onTap: widget.isSelecting // 如果是選地點的模式，點擊事件就把選中的位置保存到 _markerLocation 中
            ? (posi) {
                setState(() {
                  _markerLocation = posi;
                });
              }
            : null,
        markers: (_markerLocation != null || widget.isSelecting == false) // 如果以選中地點或不是選地點的模式就顯示 Marker
            ? {
                Marker(
                  markerId: const MarkerId('m1'), // 設定 ID
                  position: _markerLocation ?? LatLng(widget.initLocation.lat, widget.initLocation.lng), // 設定放置 Marker 的經緯度位置
                ),
              }
            : {},
      ),
    );
  }
}
```

## 將數據保存到設備中

1. 將圖片保存到設備中：改寫 `image_input.dart` 中選取圖片的函數，將選中的圖片檔案拷貝到設備中，最終傳給父層 Place 對象的 File 為拷貝到設備中檔案，可確保檔案不會因記憶體爆掉被刪除。

```dart
import 'package:path_provider/path_provider.dart' as syspaths; // 引入 path_provider 為 syspaths
import 'package:path/path.dart' as path; // 引入 path 為 path

// 撰寫選取圖片的函數，傳入布林值判斷是否為拍攝照片
void onSelectedImg(bool isTakePicture) async {
  final ImagePicker picker = ImagePicker();
  final img = await picker.pickImage(source: isTakePicture ? ImageSource.camera : ImageSource.gallery, maxWidth: 600);
  
  if (img == null) {
    return;
  }
  
  setState(() {
    _selectedImg = File(img.path);
  });

  // 使用 syspaths.getApplicationDocumentsDirectory() 獲取設備資料夾
  final appDir = await syspaths.getApplicationDocumentsDirectory();
  // 使用 path.basename 傳入 img 的路徑，以獲取 img 的檔案名稱
  final filename = path.basename(img.path);
  // 通過 .copy() 方法傳入要放置的位置，將圖片檔案拷貝到設備資料夾中
  final copyImg = await _selectedImg!.copy('${appDir.path}/$filename');
  
  // 最後將拷貝好的圖片檔案傳給父層使用
  widget.selectedImg(copyImg);
}
```

2. 將數據保存到設備中：改寫 `places_provider.dart` 中的方法

聲明一個方法獨立於 `PlacesNotifier` 外面，用來獲取 db ：

```dart
import 'package:path/path.dart' as path; // 引入 path 為 path 下面需用到 path.join 方法
import 'package:sqflite/sqflite.dart' as sql; // 引入 sqflite 為 sql

// 宣告一個獨立的方法用來獲取 db
Future<sql.Database> _getDb() async {
  final dbPath = await sql.getDatabasesPath(); // 通過 getDatabasesPath 獲取 db 路徑
  final db = await sql.openDatabase( // 通過 openDatabase 開啟 db，如不存在就建立
    path.join(dbPath, 'places.db'), // 設置要開啟的 db，這邊通過 path.join 方法在 db 中添加一個 places.db 的資料庫
    onCreate: (db, version) { // 設置 onCreate 方法，通過 db.execute 建立名為 places 的 table
      return db.execute('CREATE TABLE places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1, // 設定版本為 1
  );
  return db; // 最後回傳 db
}
```

於 `addPlace` 中將資料 `insert` 到資料庫中：

```dart
Future<void> addPlace(Place place) async {
  final db = await _getDb(); // 獲取 db

  db.insert('places', { // 通過 db.insert 添加資料
    'id': place.id, // 傳入 id
    'title': place.title, // 傳入 title
    'image': place.image.path, // 傳入 image 的路徑
    'lat': place.location.lat, // 傳入 lat
    'lng': place.location.lng, // 傳入 lng
    'address': place.location.address, // 傳入 address
  });

  state = [place, ...state]; // 設置 state 為新的數據
}
```

添加 `getPlaces` 方法，從資料庫獲取數據：

```dart
Future<void> getData() async {
  final db = await _getDb(); // 獲取 db
  final data = await db.query('places'); // 通過 query 方法傳入 table 名獲取所有數據
  
  // 設置 state 為整理後的數據資料
  state = data
      .map( // 通過 map 方法取出所有資料並建立 Place 對象
        (e) => Place(
          id: e['id'] as String,
          title: e['title'] as String,
          image: File(e['image'] as String), // 因為是存 image 的路徑所以要用 File 包起來
          location: PlaceLocation(
            lat: e['lat'] as double,
            lng: e['lng'] as double,
            address: e['address'] as String,
          ),
        ),
      )
      .toList(); // 最後記得要 toList() 轉回陣列
}
```

最後在 `places_screen.dart` 中，將 `ListView.builder` 用 `FutureBuilder` 包起來，於初次執行 `getData` 方法初始化資料即可：

```dart
class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  late Future _placesFuture; // 宣告一個稍後賦值的 _placesFuture
  
  @override
  void initState() { // 設置 initState 方法初始化 _placesFuture
    _placesFuture = ref.read(placesProvider.notifier).getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的所有秘密基地'),
        actions: [
          IconButton(
              onPressed: () async {
                final p = await Navigator.of(context).push<Place>(MaterialPageRoute(
                  builder: (context) => const NewPlaceScreen(),
                ));
                ref.read(placesProvider.notifier).addPlace(p!);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder( // 添加 FutureBuilder 小部件在最外層
        future: _placesFuture, // 傳入稍早宣告的 _placesFuture
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : places.isEmpty
                ? const Center(
                    child: Text('尚未添加任何地點。'),
                  )
                : ListView.builder(
                    itemBuilder: (context, index) => PlaceItem(places[index]),
                    itemCount: places.length,
                  ),
      ),
    );
  }
}
```

## 補充於 `AppDelegate.swift` 中取用 env 的方法：

```swift
// 引入 flutter_config
import flutter_config

// 使用
GMSServices.provideAPIKey(FlutterConfigPlugin.env(for: "GOOGLE_API_KEY"))
```