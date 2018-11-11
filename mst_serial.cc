#include <iostream>
#include <vector>
#include <queue>
#include <functional>
#include <utility>
#include <ctime>

using namespace std;
const int MAX = 1e6 + 5;
typedef pair<long long, int> PII;
bool marked[MAX];
vector <PII> adj[MAX];
vector<long long int> parent(MAX);

/**
 * Prims Algorithm to find MST using Priority Queue
 **/
long long prim(int x) {
    priority_queue<PII, vector<PII>, greater<PII> > Q;
    int y;
    long long minimumCost = 0;
    PII p;
    // init
    Q.push(make_pair(0, x));
    parent[0] = -1;
    while(!Q.empty()) {
        // get minimum edge and corresponding node
        p = Q.top();
        Q.pop();
        x = p.second;
        long long int value = p.second;
        // Check if this node is added
        if(marked[x] == true)
            continue;
        // add edge and node to mst
        minimumCost += p.first;
        marked[x] = true;
        // update neighbours for the node
        for(int i = 0;i < adj[x].size();++i) {
            y = adj[x][i].second;
            if(marked[y] == false){
                parent[adj[x][i].second] = value;
                Q.push(adj[x][i]);
            }
        }
    }
    return minimumCost;
}

int main() {
    // inputs and init
    int nodes, edges, x, y;
    long long weight, minimumCost;
    cin >> nodes >> edges;
    for(int i = 0;i < edges;++i) {
        cin >> x >> y >> weight;
        adj[x].push_back(make_pair(weight, y));
        adj[y].push_back(make_pair(weight, x));
    }
    
    // Check execution time
    clock_t begin = clock();
    // get sum of edges in MST
    minimumCost = prim(0);
    // Stop
    clock_t end = clock();

    // Parent of nodes in MST
    // for(long long int i = 0; i < nodes; ++i){
    //     cout<<i<<"-"<<parent[i]<<"\n";
    // }

    // Result
    cout << "Sum of Edges in MST: " << minimumCost << endl;
    double elapsed_time = double(end - begin) / CLOCKS_PER_SEC;
    std::cout<<"Execution time: "<<elapsed_time<<"\n";

    return 0;
}