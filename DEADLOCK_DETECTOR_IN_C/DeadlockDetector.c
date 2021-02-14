#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<stdbool.h>

/*
	I have two struct types process and resource 
	I hold them into a arrays of processes and resources 
	When user enter the inputs program creates resources and processes 
	After that creates a adjacency matrix and search for the loop on it  (I found that kind of solution on www.geeksforgeeks.org)
	And then if program release one resource one of progress get it . To achive it I exactly copy the whole processes and resources
	for all possible scenerio . Then I run is deadlock . That way I try to find are there any possiblity of deadlock.
*/
struct Process{
	struct Resource* required;
	struct Resource* hold;
	int requiredCounter;
	int holdCounter;
	int index;
	int isVisited;
};


struct Resource{
	struct Process holder;
	struct Process* requesters;
	int isFree; 
	int holdCounter;
	char* name;
	int index;
	int numberOfRequester;
};
struct Resource* create_resource(char* name, int numberOfProcesses){
	struct Resource* rs = (struct Resource*)malloc(sizeof(struct Resource));
	rs->requesters = (struct Process*)malloc(sizeof(struct Process) * numberOfProcesses);;
	rs->isFree = 1;
	rs->holdCounter = 0;
	rs->name = name;
	rs->numberOfRequester = 0;
	return rs;
};
struct Process* create_process(int resourceSize){
	struct Process* pr = (struct Process*)malloc(sizeof(struct Process));	
	pr->required = (struct Resource*)malloc(sizeof(struct Resource) * resourceSize);
	pr->hold = (struct Resource*)malloc(sizeof(struct Resource) * resourceSize); 
	pr->requiredCounter = 0;
	pr->holdCounter = 0;
	pr->isVisited = 0;
	return pr;
}


void prints(struct Process** pr, struct Resource** rs, int number_of_process , int number_of_resources){
	printf("There are %d processes and %d resources.\n",number_of_process, number_of_resources);
	printf("Processes hold these resources:\n");
	for(int i = 0 ; i < number_of_process ;i++){
		struct Process* p = pr[i];
		
		printf("P%d:",i + 1);
		for(int j = 0; j < p->holdCounter; j++){
			struct Resource r = p->hold[j];
			printf("%c%c ",r.name[1],r.name[0]);
		}
		printf("\n");
	}
	printf("Processes request these resources.\n");
	for(int i = 0 ; i < number_of_process ;i++){
		struct Process* p = pr[i];
		printf("P%d:",i + 1);
		for(int j = 0; j < p->requiredCounter; j++){
			struct Resource r = p->required[j];
			printf("%c%c ",r.name[1],r.name[0]);
		}
		printf("\n");
	}
}

/*

	Two Helper functions release process and release resources
	Release process => release all the r';esources of the current process if it has all required resources. Remove from process list
	Releaase resource => before terminate process it should release resources.
	
*/
void release_resource(struct Process* pr, struct Resource** rL){
	/*This method get parameter that has type of struct Process which has no required resource	
	  Assume process going to */
	for(int j = 0; j < pr->holdCounter; j++){
		struct Resource res = pr->hold[j]; //resource
		res.isFree = 1; // resource is Free but still point to process
		rL[j]->isFree = 1;
	}
	pr->holdCounter = 0;

}
int* release_process(struct Process** pL, int numberOfProcesses, struct Resource** rL){
	/* To release process check if it require more resource , if not release it resource and remove it frim pL list */
	int* numberOfDeleted = (int*)malloc(sizeof(int) * 2); // deleted procecess and deleted resource
	int  numberOfDeletedProcesses=0;
	int  numberOfDeletedResources=0;
	for(int i = 0; i < numberOfProcesses; i++){
		struct Process* currentPr = pL[i]; 
		if (currentPr->requiredCounter == 0)
		{
			numberOfDeletedProcesses++;
			numberOfDeletedResources = numberOfDeletedResources + currentPr->holdCounter;
			release_resource(currentPr,rL); // release only if processs has all resources 
			/* Delete the process from pL list */
			int currentIndex = currentPr->index;
			for (int j = 0; j < numberOfProcesses - 1; j++)
			{
				if (currentIndex < j)
				{
					pL[j - 1] = pL[j];
				}
			}
		}
	}
	numberOfDeleted[0] = numberOfDeletedProcesses;
	numberOfDeleted[1] = numberOfDeletedResources;
	return numberOfDeleted;
}

void hold_new_source(struct Process* pr , struct Resource* resource, int numberOfResources){
	/*  This function will assign a process to given resource 
		All conditions gonna check when functions will be called 
	*/
	resource->holder = *pr;
	pr->hold[pr->holdCounter] = *resource;
	pr->holdCounter++;
}


int** create_adjacency(struct Process** pL, struct Resource** rL, int numberOfResources, int numberOfProcesses){

	int** adjacency_array = (int**)malloc(sizeof(int*) * numberOfProcesses);
	for (int i = 0; i < numberOfProcesses; i++)
	{
		adjacency_array[i] =(int*) malloc(sizeof(int) * numberOfResources);
		for(int j = 0; j < numberOfResources; j++){
      		adjacency_array[i][j] = -1;
    	}
	}
	for (int i = 0; i < numberOfProcesses; i++)
	{
		struct Process* pr = pL[i];
		for (int j = 0; j < numberOfResources; j++)
		{
			struct Resource* res = rL[j];
			if (pr->index != res->holder.index)
			{
				for (int k = 0; k < numberOfResources; k++)
				{
					if (adjacency_array[pr->index][k] == -1 )
					{
						adjacency_array[pr->index][k] = res->holder.index;
						break;
					}
					
				}
				
			}
			
		}
		
	}
	return adjacency_array;
}
int** make_square_matrix(int** mtr, int w , int h){
	int bigger ;
	if (w < h)
	{
		bigger = h;
	}else
	{
		bigger = w;
	}
	int** sqr_mtr = (int**)malloc(sizeof(int*) * bigger);
	for (int i = 0; i < bigger; i++)
	{
		sqr_mtr[i] =(int*) malloc(sizeof(int) * bigger);
		for(int j = 0; j < bigger; j++){
      		if (i < w && j < h)
			  {
				  sqr_mtr[i][j] = mtr[i][j];
			  }else
			  {
				  sqr_mtr[i][j] = -1;
			  }
		}
	}
	return sqr_mtr;
}
/* Helper functions for copy whole lists */
struct Resource* copyResource(struct Resource* res, int numberOfResources, int numberOfProcesses);
struct Process* copyProcess(struct Process pr, int numberOfResources, int numberOfProcesses);

struct Process* copyProcess(struct Process pr, int numberOfResources, int numberOfProcesses){
	struct Process* processCpy = create_process(numberOfResources);
	processCpy->index = pr.index;
	processCpy->holdCounter = pr.holdCounter;
	processCpy->isVisited = pr.isVisited;
	processCpy->requiredCounter = pr.requiredCounter;
	for (int i = 0; i < pr.holdCounter; i++)
	{
		struct Resource resource = pr.hold[i];
		char* name = (char*)malloc(sizeof(char) * 2);
		struct Resource* rsC = create_resource(name, numberOfProcesses);
		rsC->index = resource.index;
		rsC->holdCounter = resource.holdCounter;
		rsC->name = resource.name;
		rsC->isFree = resource.isFree;
		processCpy->hold[i] = *rsC;
	}
	
	for (int i = 0; i < pr.requiredCounter; i++)
	{
		struct Resource resource = pr.required[i];
		char* name = (char*)malloc(sizeof(char) * 2);
		struct Resource* rsC = create_resource(name, numberOfProcesses);
		rsC->index = resource.index;
		rsC->holdCounter = resource.holdCounter;
		rsC->name = resource.name;
		rsC->isFree = resource.isFree;
		processCpy->required[i] = resource;	
	}
	return processCpy;
}

struct Resource* copyResource(struct Resource* res, int numberOfResources, int numberOfProcesses){
	
	char* name = (char*)malloc(sizeof(char) * 2);
	struct Resource* rsC = create_resource(name, numberOfProcesses);
	rsC->index = res->index;
	rsC->holdCounter = res->holdCounter;
	rsC->name = res->name;
	rsC->isFree = res->isFree;
	struct Process* processCpy = create_process(numberOfResources);
	processCpy->index = res->holder.index;
	processCpy->holdCounter = res->holder.holdCounter;
	processCpy->isVisited = res->holder.isVisited;
	processCpy->requiredCounter = res->holder.requiredCounter;
	rsC->holder = *processCpy;
	for (int i = 0; i < numberOfProcesses; i++)
	{
		struct Process* cpy = create_process(numberOfResources);
		struct Process reqPr = res->requesters[i];
		cpy->index = reqPr.index;
		cpy->holdCounter = reqPr.holdCounter;
		cpy->isVisited = reqPr.isVisited;
		cpy->requiredCounter = reqPr.requiredCounter;
		rsC->requesters[i] = *cpy;
	}
	rsC->numberOfRequester = res->numberOfRequester;
	return rsC;
}

void copyListOfResource(struct Resource** rL, struct Resource** dest, int numberOfResources, int numberOfProcesses){
	for (int i = 0; i < numberOfResources; i++)
	{
		dest[i] = copyResource(rL[i],numberOfResources,numberOfProcesses);
	}
}
void copyListOfProcess(struct Process** pL, struct Process** dest, int numberOfResources, int numberOfProcesses){
	for (int i = 0; i < numberOfProcesses; i++)
	{
		dest[i] = copyProcess(*pL[i],numberOfResources,numberOfProcesses);
	}
	
}
bool is_cyclic_util(int** adjacency_array, int number_of_vertices, int v, bool* visited, bool* rec_stack){

  if(visited[v] == false){
    visited[v] = true;
    rec_stack[v] = true;

    int* current = adjacency_array[v];
    for(int i = 0; i < number_of_vertices; i++){
      if(current[i] == -1){
        break;
      }
      if(!visited[current[i]] && is_cyclic_util(adjacency_array, number_of_vertices, current[i], visited, rec_stack)){
        return true;
      }
      else if(rec_stack[current[i]]){
        return true;
      }
    }
  }

  rec_stack[v] = false;
  return false;
}
bool is_cyclic(int** adjacency_array, int number_of_vertices){
  bool* visited = (bool*)malloc(number_of_vertices * sizeof(bool));
  bool* rec_stack = (bool*)malloc(number_of_vertices * sizeof(bool));

  for(int i = 0; i < number_of_vertices; i++){
    visited[i] = false;
    rec_stack[i] = false;
  }

  for(int j = 0; j < number_of_vertices; j++){
    if(is_cyclic_util(adjacency_array, number_of_vertices, j, visited, rec_stack)){
      return true;
    }
  }
  free(visited);
  free(rec_stack);
  return false;
}
bool isDeadLock(struct Process** pL, struct Resource** rL, int numberOfProcesses, int numberOfResources){
	int  numberOfDeletedProcesses = 0;
	int  numberOfDeletedResources = 0;
	bool isDeadLock = false;
	do
	{
		int* number_of_deleted = release_process(pL,numberOfProcesses,rL);
		int  numberOfDeletedProcesses = number_of_deleted[0];
		int  numberOfDeletedResources = number_of_deleted[1];
		numberOfProcesses = numberOfProcesses - numberOfDeletedProcesses;
		
		
		if ( numberOfDeletedResources == 0 )
		{
			int** mtr = create_adjacency(pL,rL,numberOfResources,numberOfProcesses);
			
			int** sqr_mtr = make_square_matrix(mtr,numberOfProcesses,numberOfResources);
			
			isDeadLock = isDeadLock || is_cyclic(sqr_mtr,numberOfProcesses);
			
		}else
		{
			/* On this part we know that we have a free resources */
			int countFreeResource = 0;
			for (int i = 0; i < numberOfResources; i++)
			{
		
				struct Resource* resource = rL[i];
			
				if (resource->isFree == 1)
				{
					countFreeResource++;
				
					for (int i = 0; i < resource->numberOfRequester; i++)
					{
						/* Working on copy arrays */
						printf("%d\n", countFreeResource);
						for (int j = 0; j < numberOfProcesses; j++)
						{
							struct Resource** copyRL = (struct Resource**)malloc(sizeof(struct Resource) * numberOfResources);	// Create Copy Resource array
							struct Process** copyPL= (struct Process**)malloc(sizeof(struct Process) * numberOfProcesses); 		// Create Copy Process array
							
							copyListOfResource(rL,copyRL,numberOfResources,numberOfProcesses);		 // Copy array (shallow) 
							copyListOfProcess(pL,copyPL,numberOfResources,numberOfProcesses);		//  Copy array (shallow)
							
							for (int k = 0; k < numberOfProcesses; k++)
							{
								struct Process currPr = copyRL[resource->index]->requesters[j];
								struct Resource* resourceCopy = copyRL[i]; 
								hold_new_source(&currPr, resourceCopy, numberOfResources); // current process allocate resource
								int** mtr = create_adjacency(pL,rL,numberOfResources,numberOfProcesses);
								int** sqr_mtr = make_square_matrix(mtr,numberOfResources,numberOfProcesses);
								isDeadLock = isDeadLock || is_cyclic(sqr_mtr,numberOfProcesses);
								
							}
							free(copyRL);
							free(copyPL);
						}
						
					}
					
				}
			
			}
		}
		if (isDeadLock)
		{
			printf("DEADLOCK IS POSSIBLE\n");
		}else
		{
			printf("DEADLOCK NOT POSSIBLE \n");
		}

	} while (numberOfDeletedProcesses > 0 );
	return true;
}
int main(int argv, char **args){
	int numberOfProcesses = argv -  1; // First one is the executable name  
	int numberOfResources= strlen(args[1]);	   // Assume that perfect user and gives the All Input correct
	
	struct Process** pL= (struct Process**)malloc(sizeof(struct Process) * numberOfProcesses); // Create Process List

	struct Resource** rL = (struct Resource**)malloc(sizeof(struct Resource) * numberOfResources);	// Create Resource list

	
	for(int i = 0; i < numberOfProcesses; i++){
		struct Process* pr = create_process(numberOfResources);
		pr->index = i;	     
		pL[i] = pr;  // Add all processes to the pL process list 
	}
	for(int i = 0; i < numberOfResources; i++){
		char* name = (char*)malloc(sizeof(char) * 2);
		
		sprintf(name, "%d", i + 1); 
		name[1] = 'R';
		struct Resource* rs = create_resource(name, numberOfProcesses);
		rs->index = i;     
		rL[i] = rs;  // Add all resource to the rL resource list 
	}
	/* Creation Of Elements is Done */
	for(int i = 1; i <= numberOfProcesses; i++){
		struct Process* pr = pL[i - 1];
		for(int j = 0; j < numberOfResources; j++){
			char specialChar = args[i][j];
			if(specialChar == 'H'){
				pr->hold[pr->holdCounter] = *rL[j];
				pr->holdCounter = pr->holdCounter + 1;
				struct Resource* resource = rL[j];
				resource->holder = *pr;
				resource->isFree = 0;
			}else if(specialChar == 'R'){
				struct Process* pr = pL[i - 1];
				pr->required[pr->requiredCounter] = *rL[j];
				pr->requiredCounter++;
				struct Resource* resource = rL[j];
				resource->requesters[i - 1] = *pr;
				resource->numberOfRequester++;
			}else if(specialChar == 'X'){
	
			}else{
				return -1;			
			}
		}	
	}
	prints(pL,rL,numberOfProcesses,numberOfResources);
	
	isDeadLock(pL,rL,numberOfProcesses,numberOfResources);
	
return 0;
}
