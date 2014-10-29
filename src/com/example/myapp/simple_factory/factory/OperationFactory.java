package com.example.myapp.simple_factory.factory;

import com.example.myapp.simple_factory.Operation;
import com.example.myapp.simple_factory.impl.AddOperation;
import com.example.myapp.simple_factory.impl.SubtractionOperation;

/**
 * Created by sjyin on 14-10-15.
 */
public class OperationFactory {
    private Operation operation;
    public Operation getOperation(int symbol){
        switch (symbol){
            case 1:
                operation = new AddOperation();
                break;
            case 2:
                operation = new SubtractionOperation();
                break;
            default:
                break;
        }
        return operation;
    }
}
