#include <bits/stdc++.h>
#define INF 100

using namespace std;

int main(){

    srand(time(NULL));
    
    int nodes;
    cin>>nodes;

    vector<vector<pair<int,int> > > adjacency(nodes);

    int extra_edges = ((nodes - 1) * nodes)/2 - (nodes-1);
    extra_edges = rand() % (extra_edges + 1);

    vector<int> graph(nodes);
    
    for(int i = 0; i < nodes; ++i){
        graph[i] = i;
    }   

    random_shuffle(graph.begin(),graph.end());

    set<pair<int,int> > present_edge;

    for(int i = 1; i < nodes; ++i){
        int add = random() % i;
        int weight = random() % INF;
        adjacency[graph[i]].push_back(make_pair(graph[add], weight));
        adjacency[graph[add]].push_back(make_pair(graph[i], weight));
        present_edge.insert(make_pair(min(graph[add], graph[i]), max(graph[add], graph[i])));
    }

    for(int i = 1; i <= extra_edges; ++i){
        int weight = rand() % INF;
        while(1){
            int node1 = rand() % nodes;
            int node2 = rand() % nodes;
            if(present_edge.find(make_pair(min(node1, node2), max(node1, node2))) == present_edge.end()){
                adjacency[node1].push_back(make_pair(node2, weight));
                adjacency[node2].push_back(make_pair(node1, weight));
                present_edge.insert(make_pair(min(node1, node2), max(node1, node2)));
                break;
            }
        }
    }

    cout<<nodes<<" "<<nodes-1+extra_edges<<"\n";

    for(int i = 0; i < nodes; ++i){
        for(int j = 0; j < adjacency[i].size(); ++j){
            if(i < adjacency[i][j].first){
                cout<<i<<" "<<adjacency[i][j].first<<" "<<adjacency[i][j].second<<"\n";
            }
        }
    }

    return 0;
}