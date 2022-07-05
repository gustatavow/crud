import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  //inicializar app e firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To testando',
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          accentColor: Colors.red),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// text fields' controllers
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
//acesar a tabela que criei com o nome de produtos no firebase
  final CollectionReference _produtos =
      FirebaseFirestore.instance.collection('produtos');

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _valorController,
                  decoration: const InputDecoration(
                    labelText: 'valor',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Adicionar'),
                  onPressed: () async {
                    final String nome = _nomeController.text;
                    final double? valor =
                        double.tryParse(_valorController.text);
                    if (valor != null) {
                      await _produtos.add({"nome": nome, "valor": valor});

                      _nomeController.text = 'nome';
                      _valorController.text = 'valor';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nomeController.text = documentSnapshot['nome'];
      _valorController.text = documentSnapshot['valor'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'nome'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _valorController,
                  decoration: const InputDecoration(
                    labelText: 'valor',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Editar'),
                  onPressed: () async {
                    final String nome = _nomeController.text;
                    final double? valor =
                        double.tryParse(_valorController.text);
                    if (valor != null) {
                      await _produtos
                          .doc(documentSnapshot!.id)
                          .update({"nome": nome, "valor": valor});
                      _nomeController.text = '';
                      _valorController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _delete(String productId) async {
    await _produtos.doc(productId).delete();
// mensagem caso consiga deletar a tabela
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você conseguiu deletar o que queria')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Atividade Avaliativa Crud')),
      ),
      //stream builder pois ele vai fazer com que tenha dados atualizado do firebase
      //Snapshot ajuda com uma conexão persistente com a tabela do firebase
      body: StreamBuilder(
        stream: _produtos.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(5),
                  child: ListTile(
                    title: Text(documentSnapshot['nome']),
                    subtitle: Text(documentSnapshot['valor'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          //Pressione botão para editar esse produto
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _update(documentSnapshot)),
                          //Pressione botão para deletar esse produto
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
// button pra add uma nova tabela
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
