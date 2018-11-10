#include <bits/stdc++.h>
#define INF 100
#define MAX_NODES 1000000

using namespace std;

int main(){

    srand(time(NULL));

    ios_base::sync_with_stdio(false);
    cin.tie(NULL);
    cout.tie(NULL);
    
    // nodes<=MAX_NODES

    long long int nodes;
    cin>>nodes;

    vector<vector<pair<long long int, long long int> > > adjacency(nodes);

    long long int extra_edges = ((nodes - 1) * nodes)/2 - (nodes-1);
    extra_edges = rand() % (extra_edges + 1);

    if(nodes - 1 + extra_edges > MAX_NODES){
        long long int difference = MAX_NODES - (nodes - 1);
        extra_edges = rand() % (difference + 1);
    }

    vector<long long int> graph(nodes);
    
    for(long long int i = 0; i < nodes; ++i){
        graph[i] = i;
    }   

    random_shuffle(graph.begin(),graph.end());

    set<pair<long long int, long long int> > present_edge;

    for(long long int i = 1; i < nodes; ++i){
        long long int add = random() % i;
        long long int weight = random() % INF;
        adjacency[graph[i]].push_back(make_pair(graph[add], weight));
        adjacency[graph[add]].push_back(make_pair(graph[i], weight));
        present_edge.insert(make_pair(min(graph[add], graph[i]), max(graph[add], graph[i])));
    }

    for(long long int i = 1; i <= extra_edges; ++i){
        long long int weight = rand() % INF;
        while(1){
            long long int node1 = rand() % nodes;
            long long int node2 = rand() % nodes;
            if(node1 == node2) continue;
            if(present_edge.find(make_pair(min(node1, node2), max(node1, node2))) == present_edge.end()){
                adjacency[node1].push_back(make_pair(node2, weight));
                adjacency[node2].push_back(make_pair(node1, weight));
                present_edge.insert(make_pair(min(node1, node2), max(node1, node2)));
                break;
            }
        }
    }

    cout<<nodes<<" "<<nodes-1+extra_edges<<"\n";

    for(long long int i = 0; i < nodes; ++i){
        for(long long int j = 0; j < adjacency[i].size(); ++j){
            if(i < adjacency[i][j].first){
                cout<<i<<" "<<adjacency[i][j].first<<" "<<adjacency[i][j].second<<"\n";
            }
        }
    }

    return 0;
}