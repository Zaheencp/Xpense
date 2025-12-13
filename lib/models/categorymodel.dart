
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Expensecategory{
final  String? name;
final IconData? icon;
final transactiontype? type;
Expensecategory({ this.name, this.icon,this.type});



static  List<Expensecategory> expenses = [
    Expensecategory(name: 'food', icon: FontAwesomeIcons.bowlFood,type: transactiontype.expence),
    Expensecategory(name: 'transportation', icon: FontAwesomeIcons.trainSubway,type: transactiontype.expence),
    Expensecategory(name: 'bills', icon: FontAwesomeIcons.moneyBillTransfer,type: transactiontype.expence),
    Expensecategory(name: 'home', icon: FontAwesomeIcons.house,type: transactiontype.expence),
    Expensecategory(name: 'car', icon: FontAwesomeIcons.car,type: transactiontype.expence),
    Expensecategory(name: 'entertainment', icon: FontAwesomeIcons.gamepad,type: transactiontype.expence),
    Expensecategory(name: 'shopping', icon: FontAwesomeIcons.shop,type: transactiontype.expence),
    Expensecategory(name: 'clothing', icon: FontAwesomeIcons.personDress,type: transactiontype.expence),
    Expensecategory(name: 'insurance', icon: FontAwesomeIcons.shield,type: transactiontype.expence),
    Expensecategory(name: 'cigerette', icon: FontAwesomeIcons.smoking,type: transactiontype.expence),
    Expensecategory(name: 'telephone', icon: FontAwesomeIcons.phone,type: transactiontype.expence),
    Expensecategory(name: 'health', icon: FontAwesomeIcons.suitcaseMedical,type: transactiontype.expence),
    Expensecategory(name: 'sports', icon: FontAwesomeIcons.dumbbell,type: transactiontype.expence),
    Expensecategory(name: 'baby', icon: FontAwesomeIcons.babyCarriage,type: transactiontype.expence),
    Expensecategory(name: 'pet', icon: FontAwesomeIcons.dog,type: transactiontype.expence),
    Expensecategory(name: 'education', icon: FontAwesomeIcons.school,type: transactiontype.expence),
    Expensecategory(name: 'travel', icon: FontAwesomeIcons.plane,type: transactiontype.expence),
    Expensecategory(name: 'gift', icon: FontAwesomeIcons.gifts,type: transactiontype.expence),
  ];
  static List<Expensecategory> incomes = [
    Expensecategory(name: 'salary', icon: FontAwesomeIcons.wallet,type: transactiontype.income),
    Expensecategory(name: 'awards', icon: FontAwesomeIcons.sackDollar,type: transactiontype.income),
    Expensecategory(name: 'grant', icon: FontAwesomeIcons.gift,type: transactiontype.income),
    Expensecategory(name: 'sale', icon: FontAwesomeIcons.house,type: transactiontype.income),
    Expensecategory(name: 'refund', icon: FontAwesomeIcons.car,type: transactiontype.income),
    Expensecategory(name: 'lottery', icon: FontAwesomeIcons.car,type: transactiontype.income),
    Expensecategory(name: 'coupens', icon: FontAwesomeIcons.car,type: transactiontype.income),
    Expensecategory(name: 'investment', icon: FontAwesomeIcons.car,type: transactiontype.income),

    

   ];
}
enum transactiontype{
  income,
  expence
}

