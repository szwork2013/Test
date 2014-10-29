package com.example.myapp.simple_factory;

import com.example.myapp.simple_factory.factory.OperationFactory;

/**
 * Created by sjyin on 14-10-15.
 */
public class Client {

    public static void main(String[] args){
        OperationFactory factory = new OperationFactory();
        Operation operation = factory.getOperation(1);
        operation.num1 = 1;
        operation.num2 = 2;
        double result = operation.getResult();
        System.out.print("result == " + result);
    }
}
