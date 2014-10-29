package com.example.myapp.simple_factory.impl;

import com.example.myapp.simple_factory.Operation;

/**
 * Created by sjyin on 14-10-15.
 */
public class SubtractionOperation extends Operation
{
    @Override
    public double getResult() {
        return num1 - num2;
    }
}
