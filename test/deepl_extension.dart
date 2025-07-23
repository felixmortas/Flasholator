import 'package:http/http.dart';
import 'dart:convert';

// https://www2.deepl.com/jsonrpc?client=chrome-extension,1.12.3

// headers = {
//     "User-Agent": "DeepLBrowserExtension/1.12.3 Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0",
//     "Accept": "*/*",
//     "Accept-Encoding": "gzip, deflate, br, zstd",
//     "Content-Type": "application/json; charset=utf-8",
//     "Authorization": "None",
//     "Content-Length": "170", // !\ Pas obligatoire mais bonne pratique : changer en fonction de la taille du body (en octets)
//     "Origin": "moz-extension://be821fe0-1fca-40a2-8c18-85b0dc4673e8",
//     "DNT": "1",
//     "Sec-Fetch-Dest": "empty",
//     "Sec-Fetch-Mode": "cors",
//     "Sec-Fetch-Site": "same-origin",
//     "Referer": "https://www.deepl.com/",
//     "Priority": "u=4"
//   };

// body = json.encode({
//     "jsonrpc": "2.0",
//     "method": "LMT_handle_texts",
//     "params": {
//         "texts": [{"text": "Chaud"}],
//         "lang": {
//             "target_lang": "EN",
//             "source_lang_user_selected": "FR",
//         },
//         "timestamp": 1725029564012 // !\ obligatoire : heure en milisecondes, à calculer
//     },
// });
