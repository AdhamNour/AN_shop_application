import 'dart:math';

import 'package:AN_shop_application/constant_and_enums.dart';
import 'package:AN_shop_application/models/shopping_models/product.dart';
import 'package:AN_shop_application/screens/messagesScreen.dart';
import 'package:AN_shop_application/widgets/Seller.dart';
import 'package:AN_shop_application/widgets/shopping_widgets/Adding_To_Cart_fav.dart';
import 'package:AN_shop_application/widgets/shopping_widgets/SABT.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/ProductDetailsScreen';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation degOneTranslate, rotationAnimation;

  void translationalMoving() {
    setState(() {});
  }

  double getRadianFromDegree(double degree) {
    double unitRadial = 180 / pi;
    return degree / unitRadial;
  }

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    degOneTranslate = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.elasticInOut));
    rotationAnimation = Tween(begin: 0.0, end: 2 * pi).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    super.initState();
    animationController.addListener(translationalMoving);
  }

  @override
  Widget build(BuildContext context) {
    final Product _product =
        ModalRoute.of(context).settings.arguments as Product;
    final isOwner = _product.ownerID == FirebaseAuth.instance.currentUser.uid;

    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      child: Stack(
        children: [
          ProductDataisScreenContent(size: size, product: _product),
          if (!isOwner)
            Positioned(
              bottom: 20,
              right: 20,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  IgnorePointer(
                    child: Container(
                      height: 150.0,
                      width: 150.0,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(
                        getRadianFromDegree(270), 100 * degOneTranslate.value),
                    child: Transform.rotate(
                        angle: rotationAnimation.value,
                        child: Builder(
                          builder: (context) => CircularButton(
                            50,
                            Icon(Icons.shopping_cart),
                            Colors.deepOrange,
                            onClick: () {
                              addToCart(context, _product);
                            },
                          ),
                        )),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(
                        getRadianFromDegree(225), 100 * degOneTranslate.value),
                    child: Transform.rotate(
                        angle: rotationAnimation.value,
                        child: Builder(
                          builder: (context) => CircularButton(
                            50,
                            Icon(Icons.account_circle),
                            Colors.deepPurple,
                            onClick: () {
                              chatWithOwner(context, _product.ownerID);
                            },
                          ),
                        )),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(
                        getRadianFromDegree(180), 100 * degOneTranslate.value),
                    child: Transform.rotate(
                      angle: (2 * pi) - rotationAnimation.value,
                      child: CircularButton(
                        50,
                        null,
                        Colors.cyanAccent,
                        doneWidget: Builder(
                          builder: (context) =>
                              buildConsumer(context, _product),
                        ),
                      ),
                    ),
                  ),
                  CircularButton(50, Icon(Icons.add), Colors.blue[900],
                      onClick: () {
                    if (animationController.isCompleted) {
                      animationController.reverse();
                    } else {
                      animationController.forward();
                    }
                  }),
                ],
              ),
            ),
        ],
      ),
      height: size.height,
      width: size.width,
    ));
  }
}

class ProductDataisScreenContent extends StatefulWidget {
  ProductDataisScreenContent({
    @required this.size,
    @required this.product,
  });

  final Size size;
  final Product product;

  @override
  _ProductDataisScreenContentState createState() =>
      _ProductDataisScreenContentState();
}

class _ProductDataisScreenContentState
    extends State<ProductDataisScreenContent> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 4 * widget.size.height / 5,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SABT(child: Text(widget.product.name)),
              ),
              background: Hero(
                tag: widget.product.id,
                child: CachedNetworkImage(
                    imageUrl: widget.product.imageURL,
                    fit: BoxFit.fill,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error)),
              ),
              centerTitle: true,
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('Owner: '),
                  Expanded(child: SellerWidget(widget.product.ownerID,onTap: ()=>chatWithOwner(context,widget.product.ownerID),))
                  
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.product.description),
            ),
          ])),
        ],
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final double r;
  final Color color;
  final Icon icon;
  final Function onClick;
  final Widget doneWidget;
  CircularButton(this.r, this.icon, this.color,
      {this.onClick, this.doneWidget});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      height: r,
      width: r,
      child: onClick == null
          ? doneWidget
          : IconButton(
              icon: icon,
              onPressed: onClick,
              enableFeedback: true,
            ),
    );
  }
}


void chatWithOwner(BuildContext context,String ownerID){
  if(ownerID == FirebaseAuth.instance.currentUser.uid){
    return;
  }
  Navigator.of(context).pushNamed(MessagesScreen.routeName,arguments: ownerID);
}