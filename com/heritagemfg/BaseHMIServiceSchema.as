package com.heritagemfg
{
	 import mx.rpc.xml.Schema
	 public class BaseHMIServiceSchema
	{
		 public var schemas:Array = new Array();
		 public var targetNamespaces:Array = new Array();
		 public function BaseHMIServiceSchema():void
		{
			 var xsdXML0:XML = <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2001/XMLSchema" xmlns:apachesoap="http://xml.apache.org/xml-soap" xmlns:impl="http://flash.queries.flex.console" xmlns:intf="http://flash.queries.flex.console" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns1="http://rpc.xml.coldfusion" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:wsdlsoap="http://schemas.xmlsoap.org/wsdl/soap/" attributeFormDefault="unqualified" elementFormDefault="unqualified" targetNamespace="http://rpc.xml.coldfusion">
    <xsd:import namespace="http://schemas.xmlsoap.org/soap/encoding/"/>
    <xsd:complexType name="CFCInvocationException">
        <xsd:sequence/>
    </xsd:complexType>
    <xsd:complexType name="QueryBean">
        <xsd:sequence>
            <xsd:element name="columnList" nillable="true" type="intf:ArrayOf_xsd_string"/>
            <xsd:element name="data" nillable="true" type="intf:ArrayOfArrayOf_xsd_anyType"/>
        </xsd:sequence>
    </xsd:complexType>
</xsd:schema>
;
			 var xsdSchema0:Schema = new Schema(xsdXML0);
			schemas.push(xsdSchema0);
			targetNamespaces.push(new Namespace('','http://rpc.xml.coldfusion'));
			 var xsdXML1:XML = <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2001/XMLSchema" xmlns:apachesoap="http://xml.apache.org/xml-soap" xmlns:impl="http://flash.queries.flex.console" xmlns:intf="http://flash.queries.flex.console" xmlns:ns0="http://rpc.xml.coldfusion" xmlns:ns1="http://rpc.xml.coldfusion" xmlns:ns4="http://rpc.xml.coldfusion" xmlns:ns5="http://rpc.xml.coldfusion" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns1="http://rpc.xml.coldfusion" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:wsdlsoap="http://schemas.xmlsoap.org/wsdl/soap/" attributeFormDefault="unqualified" elementFormDefault="unqualified" targetNamespace="http://flash.queries.flex.console">
    <xsd:import namespace="http://schemas.xmlsoap.org/soap/encoding/"/>
    <xsd:import namespace="http://rpc.xml.coldfusion"/>
    <xsd:import namespace="http://rpc.xml.coldfusion"/>
    <xsd:import namespace="http://rpc.xml.coldfusion"/>
    <xsd:import namespace="http://rpc.xml.coldfusion"/>
    <xsd:complexType name="ArrayOf_xsd_string">
        <xsd:complexContent>
            <xsd:restriction base="soapenc:Array">
                <xsd:attribute ref="soapenc:arrayType" wsdl:arrayType="xsd:string[]"/>
            </xsd:restriction>
        </xsd:complexContent>
    </xsd:complexType>
    <xsd:complexType name="ArrayOfArrayOf_xsd_anyType">
        <xsd:complexContent>
            <xsd:restriction base="soapenc:Array">
                <xsd:attribute ref="soapenc:arrayType" wsdl:arrayType="xsd:anyType[][]"/>
            </xsd:restriction>
        </xsd:complexContent>
    </xsd:complexType>
    <xsd:element name="ListDealersByState">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="state" type="string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="ListDealersByName">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="name" type="string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="WhoAmI">
        <xsd:complexType>
            <xsd:sequence/>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="ListDealersByStateResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="ListDealersByStateReturn" type="tns1:QueryBean"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="ListDealersByNameResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="ListDealersByNameReturn" type="tns1:QueryBean"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="WhoAmIResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="WhoAmIReturn" type="string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="ListDealersByState">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="state" type="string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="ListDealersByName">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="name" type="string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="WhoAmI">
        <xsd:complexType>
            <xsd:sequence/>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="ListDealersByStateResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="ListDealersByStateReturn" type="tns1:QueryBean"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="ListDealersByNameResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="ListDealersByNameReturn" type="tns1:QueryBean"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="WhoAmIResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="WhoAmIReturn" type="string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>
;
			 var xsdSchema1:Schema = new Schema(xsdXML1);
			schemas.push(xsdSchema1);
			targetNamespaces.push(new Namespace('','http://flash.queries.flex.console'));
			xsdSchema1.addImport(new Namespace("http://rpc.xml.coldfusion"), xsdSchema0)
		}
	}
}