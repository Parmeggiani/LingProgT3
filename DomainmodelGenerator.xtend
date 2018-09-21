package org.xtext.domainmodel.generator
     
    import org.eclipse.emf.ecore.resource.Resource
    import org.eclipse.xtext.generator.AbstractGenerator
    import org.eclipse.xtext.generator.IFileSystemAccess2
    import org.eclipse.xtext.generator.IGeneratorContext
    import org.eclipse.xtext.naming.IQualifiedNameProvider
     
    import com.google.inject.Inject
	import org.xtext.domainmodel.domainmodel.Entity
	import org.xtext.domainmodel.domainmodel.Feature

class DomainmodelGenerator extends AbstractGenerator {
     
        @Inject extension IQualifiedNameProvider
     
        override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) 
        {
            for (e : resource.allContents.toIterable.filter(Entity)) 
            {
                fsa.generateFile(e.fullyQualifiedName.toString("/") + ".cpp", e.compile)
            }
        }
     
     	def genFileReader(Entity e)'''
     	string «'readFile'»(string filePath)
     	{
     	    «'ifstream rFile'»;
     	    «'rFile.open(filePath)'»;
     	
     	    «'stringstream strStream'»;
     	    «'strStream << rFile.rdbuf()'»;

     	    return «'szStream.str()'»;
     	}
     	'''
     
        def compile(Entity e) ''' 
			«IF e.name.contains("FileReader")»
			#include<iostream>
			#include<ifstream>
			#include<sstream>
			«ENDIF»

		using namespace std;
            «IF e.eContainer.fullyQualifiedName !== null»
           		«val packageName = e.eContainer.fullyQualifiedName.toString»
           		«val index = packageName.lastIndexOf(".")»
           		«val nameSpace = packageName.substring(index+1)»
           		using namespace «nameSpace»;
            «ENDIF»

		class «e.name»«IF e.superType !== null» : «e.superType.name» «ENDIF»{
		
		private:
                «FOR f : e.features»
                    «f.setVariables»
                «ENDFOR»
		public:
		    «e.name»(){}
                «FOR f : e.features»
                   «f.gettersAndSetters»
                «ENDFOR» 

        		«IF e.name.contains("FileReader")»
           			«e.genFileReader»
        		«ENDIF»
		}
        '''
  
        def setVariables(Feature f) '''
        «var vectorType = "vector<" + f.type.name + ">"»
        «IF f.isMany»
        	«vectorType» «f.name»;
        «ELSE»
        	«f.type.fullyQualifiedName.toString.toFirstLower» «f.name»;
        «ENDIF»
        '''
        
        def gettersAndSetters(Feature f) '''
        «var vectorType = "vector<" + f.type.name + ">"»
        «IF f.isMany»
           	«vectorType» get«f.name.toFirstUpper»(){ return this->«f.name»; }
           	
           	void set«f.name.toFirstUpper»(«vectorType» «f.name»){ this->«f.name» = «f.name»; }
        «ELSE»
            «f.type.name.toFirstLower» get«f.name.toFirstUpper»(){ return this->«f.name»; }
            
            void set«f.name.toFirstUpper»(«f.type.name.toFirstLower» «f.name»){ this->«f.name» = «f.name»; }
        «ENDIF»
        
        '''
    }