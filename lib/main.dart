import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/api_service.dart';

const azulApp = Color(0xFF0A95AE);
const azulClaro = Color(0xFFCAE7F5);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurante',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: azulApp),
        appBarTheme: AppBarTheme(
          backgroundColor: azulApp,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User? _user;
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      await GoogleSignIn().signOut();
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isSigningIn = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      setState(() {
        _user = userCredential.user;
        _isSigningIn = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MenuPage()),
      );
    } catch (e) {
      setState(() => _isSigningIn = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [azulApp, azulClaro],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Iniciar sesión'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child:
              _user == null
                  ? _isSigningIn
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: azulApp,
                          foregroundColor: Colors.white,
                          elevation: 4,
                        ),
                        icon: Icon(Icons.login, size: 28),
                        label: Text(
                          'Iniciar sesión con Google',
                          style: TextStyle(fontSize: 17),
                        ),
                        onPressed: _signInWithGoogle,
                      )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(_user!.photoURL ?? ''),
                        radius: 40,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Bienvenido, ${_user!.displayName ?? 'usuario'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _signOut,
                        child: Text('Cerrar sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: azulApp,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

// Pantalla principal: Menú del restaurante
class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<dynamic>> _menusFuture;

  @override
  void initState() {
    super.initState();
    _menusFuture = ApiService.obtenerMenus();
  }

  void _abrirMenuCategoria(Map<String, dynamic> menu) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (_, __, ___) => MenuCategoriaPage(
              categoryToken: menu['category']['token'],
              categoryName: menu['category']['name'] ?? '',
            ),
        transitionsBuilder:
            (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [azulApp, azulClaro],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Menú del restaurante',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _menusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No hay menús para mostrar',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              final menus = snapshot.data!;
              return ListView.builder(
                itemCount: menus.length,
                padding: EdgeInsets.only(top: 12, bottom: 18),
                itemBuilder: (context, index) {
                  final menu = menus[index];
                  final categoria =
                      menu['category']?['name'] ?? 'Sin categoría';

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => _abrirMenuCategoria(menu),
                      child: Card(
                        color: Colors.white.withOpacity(0.92),
                        elevation: 7,
                        shadowColor: azulApp.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 22,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                color: azulApp,
                                size: 36,
                              ),
                              SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  categoria,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: azulApp,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: azulApp,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

// Menú por Categoría + evaluación y POPUP
class MenuCategoriaPage extends StatefulWidget {
  final String categoryToken;
  final String categoryName;
  const MenuCategoriaPage({
    required this.categoryToken,
    required this.categoryName,
  });

  @override
  State<MenuCategoriaPage> createState() => _MenuCategoriaPageState();
}

class _MenuCategoriaPageState extends State<MenuCategoriaPage> {
  late Future<Map<String, dynamic>> _menuFuture;
  Map<String, double> _lastRatings = {};

  @override
  void initState() {
    super.initState();
    _menuFuture = ApiService.obtenerMenuPorCategoria(widget.categoryToken);
  }

  void _rateDish(String dishToken, double rating) async {
    try {
      await ApiService.evaluarPlato(dishToken: dishToken, rate: rating.toInt());
      setState(() {
        _lastRatings[dishToken] = rating;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Evaluación enviada!'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al evaluar: $e')));
    }
  }

  void _showPopup(BuildContext context, Map plato, {bool esPlato = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: azulApp,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: EdgeInsets.all(28),
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (plato['img'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      plato['img'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (c, o, s) => Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 48,
                          ),
                    ),
                  ),
                SizedBox(height: 12),
                Text(
                  plato['name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 21,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (plato['description'] != null) ...[
                  SizedBox(height: 10),
                  Text(
                    plato['description'],
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (plato['volume'] != null && plato['unit'] != null) ...[
                  SizedBox(height: 6),
                  Text(
                    '${plato['volume']} ${plato['unit']}',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
                if (esPlato)
                  Column(
                    children: [
                      SizedBox(height: 10),
                      _RatingStars(
                        initialRating:
                            (_lastRatings[plato['token']] ??
                                plato['rate']?.toDouble() ??
                                0),
                        onRatingChanged:
                            (rating) => _rateDish(plato['token'], rating),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [azulApp, azulClaro],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Menú de ${widget.categoryName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _menuFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Text(
                  'No hay menú para esta categoría',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              final menu = snapshot.data!;
              final List<dynamic> dishes = menu['dishes'] ?? [];
              final List<dynamic> drinks = menu['drinks'] ?? [];

              return ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // SOLO SE MUESTRAN PLATOS SI HAY
                  if (dishes.isNotEmpty)
                    ...dishes.map<Widget>(
                      (plato) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap:
                              () => _showPopup(context, plato, esPlato: true),
                          child: Card(
                            color: Colors.white.withOpacity(0.18),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 22,
                                horizontal: 18,
                              ),
                              child: Row(
                                children: [
                                  if (plato['img'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        plato['img'],
                                        width: 46,
                                        height: 46,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (c, o, s) => Icon(
                                              Icons.restaurant_menu,
                                              color: Colors.white,
                                              size: 34,
                                            ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.restaurant_menu,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                  SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plato['name'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                        if (plato['description'] != null)
                                          Text(
                                            plato['description'],
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  _RatingStars(
                                    initialRating:
                                        (_lastRatings[plato['token']] ??
                                            plato['rate']?.toDouble() ??
                                            0),
                                    onRatingChanged:
                                        (rating) =>
                                            _rateDish(plato['token'], rating),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // SOLO SE MUESTRAN BEBIDAS SI HAY
                  if (drinks.isNotEmpty)
                    ...drinks.map<Widget>(
                      (drink) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GestureDetector(
                          onTap: () => _showPopup(context, drink),
                          child: Card(
                            color: Colors.white.withOpacity(0.18),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 18,
                              ),
                              child: Row(
                                children: [
                                  if (drink['img'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        drink['img'],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (c, o, s) => Icon(
                                              Icons.local_drink,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.local_drink,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          drink['name'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (drink['volume'] != null &&
                                            drink['unit'] != null)
                                          Text(
                                            '${drink['volume']} ${drink['unit']}',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

// Widget para mostrar estrellas de rating y tocar para evaluar
class _RatingStars extends StatefulWidget {
  final double initialRating;
  final void Function(double rating) onRatingChanged;
  const _RatingStars({
    Key? key,
    required this.initialRating,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  State<_RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<_RatingStars> {
  double? _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating.clamp(1.0, 5.0);
  }

  void _handleTap(double rating) {
    setState(() => _currentRating = rating);
    widget.onRatingChanged(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = _currentRating != null && (index < _currentRating!);
        return GestureDetector(
          onTap: () => _handleTap(index + 1.0),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
        );
      }),
    );
  }
}
