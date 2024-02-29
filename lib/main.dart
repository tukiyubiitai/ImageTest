import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

void main() => runApp(MaterialApp(
  home: const MyApp(),
  theme: ThemeData(
    colorSchemeSeed: Colors.indigo,
    brightness: Brightness.dark,
  ),
));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Asset> images = <Asset>[];
  List<File> imagePicker = [];


  @override
  void initState() {
    super.initState();
  }

  Widget _buildMultiPickerGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          ),
        );
      }),
    );
  }

  Widget _buildImagePickerGridView() {
    return GridView.count(
      crossAxisCount:3, // 3列のグリッドを作成
      children: List.generate(imagePicker.length, (index) {
        File file = imagePicker[index]; // ここで各画像ファイルへの参照を取得
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Image.file(file, fit: BoxFit.cover), // 画像を表示
        );
      }),
    );
  }

  Future<List<File>> pickImagesUsingImagePicker() async {
    List<File> pickedFiles = [];
    final ImagePicker picker = ImagePicker();
    // ユーザーが複数の画像を選択できるようにします。
    var imageFiles = await picker.pickMultiImage();
    if (imageFiles.isNotEmpty) {
      // 選択された画像の数を3枚に制限します。
      int count = 0;
      for (final image in imageFiles) {
        if (count < 3) {
          pickedFiles.add(File(image.path));
          count++;
        } else {
          // 3枚を超える画像は無視します。
          break;
        }
      }
    }
    return pickedFiles;
  }


  void _loadImagesUsingImagePicker() async {
    imagePicker = await pickImagesUsingImagePicker() ;
    setState(() {});
  }


  Future<void> _loadImagesUsingMultiImagePicker() async {
    if (images.isNotEmpty) {
      images = <Asset>[]; //　初期化
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    List<Asset> resultList = <Asset>[];

    const AlbumSetting albumSetting = AlbumSetting(
      fetchResults: {
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumFavorites,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.album,
          subtype: PHAssetCollectionSubtype.albumRegular,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumPanoramas,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumVideos,
        ),
      },
    );
    const SelectionSetting selectionSetting = SelectionSetting(
      min: 0,
      max: 3,
      unselectOnReachingMax: true,
    );
    const DismissSetting dismissSetting = DismissSetting(
      enabled: true,
      allowSwipe: true,
    );
    final ThemeSetting themeSetting = ThemeSetting(
      backgroundColor: Colors.white,
      selectionFillColor: Colors.blue,
      selectionStrokeColor: Colors.white,
      previewSubtitleAttributes: const TitleAttribute(fontSize: 12.0),
      previewTitleAttributes: TitleAttribute(
        foregroundColor: colorScheme.primary,
      ),
      albumTitleAttributes: TitleAttribute(
        foregroundColor: colorScheme.primary,
      ),
    );
    const ListSetting listSetting = ListSetting(
      spacing: 5.0,
      cellsPerRow: 4,
    );
    final CupertinoSettings iosSettings = CupertinoSettings(
      fetch: const FetchSetting(album: albumSetting),
      theme: themeSetting,
      selection: selectionSetting,
      dismiss: dismissSetting,
      list: listSetting,
    );

    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: images,
        iosOptions: IOSOptions(
          doneButton:
          const UIBarButtonItem(title: '決定', tintColor: Colors.blue),
          cancelButton:
          UIBarButtonItem(title: 'キャンセル', tintColor: colorScheme.primary),
          albumButtonColor: colorScheme.primary,
          settings: iosSettings,
        ),
        androidOptions: AndroidOptions(
          actionBarColor: colorScheme.surface,
          actionBarTitleColor: colorScheme.onSurface,
          statusBarColor: colorScheme.surface,
          actionBarTitle: "Select Photo",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: colorScheme.primary,
          exceptMimeType: {MimeType.PNG, MimeType.JPEG},
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    if (resultList.isNotEmpty) {
      setState(() {
        images = resultList;
      });
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image test app'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: _loadImagesUsingMultiImagePicker,
            child: const Text("multi_image_picker_plus"),
          ),
          Expanded(
            child: _buildMultiPickerGridView(),
          ),
          ElevatedButton(
            onPressed: _loadImagesUsingImagePicker,
            child: const Text("Pick images"),
          ),
          Expanded(
            child: _buildImagePickerGridView(),
          ),
        ],
      ),
    );
  }
}