import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
class ImagemService {
 Future<String?> selecionar(ImageSource origem) async {
  final arquivo=await ImagePicker().pickImage(source:origem,maxWidth:800,maxHeight:800,imageQuality:80);
  if(arquivo==null)return null;
  final original=img.decodeImage(await arquivo.readAsBytes());
  if(original==null)throw Exception('Imagem inválida');
  var foto=img.bakeOrientation(original);
  if(foto.width>600||foto.height>600){foto=foto.width>=foto.height?img.copyResize(foto,width:600):img.copyResize(foto,height:600);}
  for(var tentativa=0;tentativa<15;tentativa++){
   final bytes=img.encodeJpg(foto,quality:tentativa<6?80-tentativa*10:25);
   if(bytes.length<=102400)return base64Encode(bytes);
   if(tentativa>=5)foto=img.copyResize(foto,width:(foto.width*0.8).round().clamp(1,600).toInt());
  }
  throw Exception('Imagem muito grande');
 }
}
