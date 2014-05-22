#include <stdio.h>
#include <stdlib.h>


typedef struct node {
	int data;
	struct node *next;
}node_t;


node_t *create_node(int );
void print_list(node_t *);
int get_nodes_count(node_t *);
void insert_before_node(node_t **);
void insert_after_node(node_t **);
void insert_first(node_t **, int);
void insert_last(node_t **, int);
void insert_at_index(node_t **, int, int);
void delete_first(node_t **);
void delete_last(node_t **);
int get_node_index(node_t *,int );
int get_element();


void delete_first(node_t **head){
	node_t *current = *head;
	int first = 0;
	if(current!=NULL){
		first = current->data;
		*head = (*head)->next;
		free(current);
		printf("Element %d removed successfully from the list\n",first);
	}else{
		printf("List is empty\n");
	}	
}



void delete_last(node_t **head){
	node_t *current = *head;
	node_t *pre_last = *head;
	int last = 0;
	while(current->next!=NULL){
		pre_last = current;
		current = current->next;
		last = current->data;
	}
	free(current);
	pre_last->next=NULL;
	printf("Element %d removed successfully from the list\n",last);
	
}

void insert_after_node(node_t **head){
	int element;
	printf("Enter the element after which node should be inserted : ");
	scanf("%d",&element);
	int index = get_node_index(*head,element);
 	if(index!=-1){
        	insert_at_index(head,get_element(),index+1);
	} else {
		printf("The element %d is not available in the list\n",element);	
	}	
}

void insert_before_node(node_t **head){
	int element;
	printf("Enter the element before which node should be inserted : ");
	scanf("%d",&element);
	int index = get_node_index(*head,element);
 	if(index!=-1){
        	insert_at_index(head,get_element(),index);
	} else {
		printf("The element %d is not available in the list\n",element);	
	}	
}

void insert_at_index(node_t **head, int value, int index) {
	
	if(index==0){
		insert_first(head,value);
	}else if(index == get_nodes_count(*head)){
		insert_last(head,value);
	}else{
		node_t *first,*second,*middle;
		node_t *current = *head;
		int i;
		for(i=0;i<index-1;i++){
			current = current->next;		
		}
		first = current;
		second = current->next;

	        middle = create_node(value);
	 	first->next = middle;
		middle->next = second;			
	}
	
}
int get_node_index(node_t *head,int value){
	node_t *current = head;
	int index = -1;
	while(current!=NULL){
		index++;
		if(current->data==value) {
			//printf("Found the element %d at the index %d\n",value,index);	
			return index;
		}
		current = current->next;	
	}	
	index = -1;
	//printf("Element %d is not available in the list\n",value); 
	return index;
}
void insert_first(node_t **head,int value){
	node_t *temp ;
	temp = create_node(value);
	if(*head == NULL ){
		//printf("Inserting node for the first time\n");
		(*head) = temp;
		return;
	}
	temp->next=(*head);	
	(*head) = temp;
}

void insert_last(node_t **head,int value){
	node_t *temp ;
	temp = create_node(value);
	if(*head == NULL ){
		//printf("Inserting node for the first time\n");
		(*head) = temp;
		return;
	}
	node_t *traverse = *head;
	node_t *last;
	while(traverse!=NULL) {
		last = traverse;
		traverse = traverse->next;
	}
	last->next = temp;	
}

void print_list(node_t *head){
	node_t *current = head;
	printf("\n");
	while(current!=NULL){
		printf("%d----->",current->data);
		current = current->next;
	}
	printf("NULL\n\n");
}
int get_nodes_count(node_t *head){
	int count=0;
	node_t *current = head;
	while(current!=NULL){
		current = current->next;
		count++;
	}
	return count;
}
node_t *create_node(int value){
	node_t *new_node = malloc(sizeof(node_t));
	if(new_node==NULL){
		printf("Memory allocation failed for the list creation. :(");
		return NULL;
	}
	new_node->data = value;
	new_node->next = NULL;
	return new_node;
}


int get_element(){
	int element;
	printf("Enter the element : ");
	scanf("%d",&element);
	return element;
}


int main(int argc, char *argv[]) {
	node_t *head = NULL;
	int user_choice = 0;
	int value = 0;
	int count = 0;
	int index = -1;
	do{
		printf("\n\n********SINGLY LINKED LIST**********\n");
		printf(" 1.Insert First\n");
		printf(" 2.Insert Last\n");
		printf(" 3.Insert After\n");
		printf(" 4.Insert Before\n");
		printf(" 5.Insert at index\n");
		printf(" 6.Delete First\n");
		printf(" 7.Delete Last\n");
		printf(" 8.Delete After\n");
		printf(" 9.Delete Before\n");
		printf("10.Delete at index\n");
		printf("11.Print List\n");
		printf("12.Count List\n");
		printf("13.Find element\n");
		printf("20.Exit\n");
		
		printf("Enter your choice : ");
		scanf("%d",&user_choice);

		switch(user_choice){
			case 1:
				insert_first(&head,get_element());
				break;
			case 2:
				insert_last(&head,get_element());
				break;
			case 3:
				insert_after_node(&head);
				break;
			case 4:
				insert_before_node(&head);
				break;
			case 5:
				printf("Enter the index : ");
				scanf("%d",&index);
			 	if(index<0 || index > get_nodes_count(head)) {
					printf("\nPlease give a valid index\n");
				}else{
					insert_at_index(&head,get_element(),index);
				}			
				break;
			case 6:
				delete_first(&head);
				break;
			case 7:
				delete_last(&head);
				break;
			case 11:
				print_list(head);
				break;
			case 12:
				count = get_nodes_count(head);
				printf("Number of elements in the list : %d\n",count);
				break;
			case 13:
				value = get_element();
				int index = get_node_index(head,value);
				if(index!=-1){
					printf("Found the element %d at the index %d\n",value,index);	
				}else{
					printf("Element %d is not available in the list\n",value); 
				}				
				break;
			case 20:
				printf("Thank you for using me.\n");
				printf("Have a nice day :)\n");
				return 0;
			default:
				printf("Please enter valid options\n");
				
		}
	}while(user_choice>=1);
	return 0;
}
