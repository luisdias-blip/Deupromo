import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(DeuPromoApp());
}

class DeuPromoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deu Promo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
      ),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  List<String> _listaCompras = [];

  void _adicionarNaLista(String item) {
    setState(() {
      _listaCompras.add(item);
    });
  }

  void _limparLista() {
    setState(() {
      _listaCompras.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(),
      ComparacaoPage(adicionarNaLista: _adicionarNaLista),
      ListaComprasPage(lista: _listaCompras, limparLista: _limparLista),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.red.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.percent),
            label: 'DP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Minha Lista',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('mercado1'),
      position: LatLng(-23.5505, -46.6333),
      infoWindow: InfoWindow(title: 'Desconto!'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
    Marker(
      markerId: MarkerId('mercado2'),
      position: LatLng(-23.5525, -46.6340),
      infoWindow: InfoWindow(title: 'Promoção!'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deu Promo'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red.shade700,
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Buscar produtos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(-23.5505, -46.6333),
                zoom: 14,
              ),
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}

class ComparacaoPage extends StatelessWidget {
  final Function(String) adicionarNaLista;

  ComparacaoPage({required this.adicionarNaLista});

  void _abrirLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Promoções'),
        backgroundColor: Colors.red.shade700,
      ),
      body: ListView(
        children: [
          _produtoCard(
            icon: Icons.local_drink,
            nome: 'Leite Integral 1L',
            mercados: [
              {
                'mercado': 'Carrefour',
                'preco': 4.99,
                'link': 'https://mercado.carrefour.com.br/leite-integral-piracanjuba-1-litro-3371689/p'
              },
              {
                'mercado': 'Lojas Funchal',
                'preco': 4.79,
                'link': 'https://www.lojasfunchal.com.br/leite-integral-1l-piracanjuba/p?idsku=31135'
              },
            ],
            onAdd: adicionarNaLista,
          ),
        ],
      ),
    );
  }

  Widget _produtoCard({
    required IconData icon,
    required String nome,
    required List<Map<String, dynamic>> mercados,
    required Function(String) onAdd,
  }) {
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.red.shade700),
        title: Text(nome),
        children: mercados.map((p) {
          return ListTile(
            title: GestureDetector(
              child: Text('${p['mercado']} – R\$ ${p['preco'].toStringAsFixed(2)}'),
              onTap: () => _abrirLink(p['link']),
            ),
            trailing: IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.red),
              onPressed: () => onAdd('$nome – ${p['mercado']} – R\$ ${p['preco'].toStringAsFixed(2)}'),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ListaComprasPage extends StatelessWidget {
  final List<String> lista;
  final VoidCallback limparLista;

  ListaComprasPage({required this.lista, required this.limparLista});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Lista'),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: limparLista,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, index) => Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            title: Text(lista[index]),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
        ),
      ),
    );
  }
}
