
unsigned int FindSpan(int n, int p, double u, double *U) {
    /* ALGORITHM A2.1, The NURBS Book, L.Piegl and W. Tiller */
    /* Determine the knot span index */
    /* Input: n,p,u,U */
    /* Return: the knot span index */
    
    unsigned int low, high, mid;
    
    if (u >= U[n-1]){
        return(n-1);
    }
    else if (u < U[p+1]){
        return(p);
    }
    low = p;  high = n;
    mid =(low+high)/2;
    while (u < U[mid] || u >= U[mid+1]) {
        if (u < U[mid]){
            high = mid;
        }
        else{
            low = mid;
        }
        mid =(low+high)/2;
    }
    return(mid);
    
}
