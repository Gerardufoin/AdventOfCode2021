Dictionary<(int x, int y), Node> map = new Dictionary<(int x, int y), Node>();
int size = 0;

String[] lines = System.IO.File.ReadAllLines(@"../input.txt");
for (int y = 0; y < lines.Count(); ++y) {
	if (size == 0) size = lines[y].Count();
	for (int x = 0; x < lines[y].Count(); ++x) {
		map.Add((x, y), new Node(lines[y][x] - '0'));
	}
}

int SolveMap(Dictionary<(int x, int y), Node> map, int size, int sizeMult) {
	PriorityQueue<(int, int), Double> toCheck = new PriorityQueue<(int, int), Double>();
	HashSet<(int, int)> added = new HashSet<(int, int)>();
	int baseSize = size;
	Node start = map[(0, 0)];

	size *= sizeMult;
	start.gScore = 0;
	start.fScore = size * 2 - 1;
	
	added.Add((0, 0));
	toCheck.Enqueue((0, 0), map[(0, 0)].fScore);
	while (toCheck.Count > 0) {
		(int x, int y) pos = toCheck.Dequeue();
		if (pos == (size - 1, size - 1)) {
			break;
		}
		added.Remove(pos);
		// Check neighbors
		for (int i = 0; i < 4; ++i) {
			int x = pos.x + i % 2 * ((i - 2) % 2);
			int y = pos.y + (i + 1) % 2 * ((i - 1) % 2);
			if (x >= 0 && x < size && y >= 0 && y < size) {
				(int x, int y) nPos = (x, y);
				if ((x >= baseSize || y >= baseSize) && !map.ContainsKey(nPos)) {
					map.Add(nPos, new Node((map[(nPos.x % baseSize, nPos.y % baseSize)].weight + nPos.x / baseSize + nPos.y / baseSize - 1) % 9 + 1));
				}
				double score = map[pos].gScore + map[nPos].weight;
				if (score < map[nPos].gScore) {
					Node nNode = map[nPos];
					nNode.comeFrom = pos;
					nNode.gScore = score;
					nNode.fScore = score + size - 1 - nPos.x + size - 1 - nPos.y;
					if (added.Add(nPos)) {
						toCheck.Enqueue(nPos, nNode.fScore);
					}
				}
			}
		}
	}
	int result = 0;
	(int, int) current = (size - 1, size - 1);
	while (current != (0, 0)) {
		result += map[current].weight;
		current = map[current].comeFrom;
	}
	return result;
}

Console.WriteLine(SolveMap(map, size, 1));
foreach (KeyValuePair<(int,int), Node> val in map) {
	val.Value.gScore = Double.PositiveInfinity;
	val.Value.fScore = Double.PositiveInfinity;
}
Console.WriteLine(SolveMap(map, size, 5));


class Node {
	public int weight;
	public double gScore;
	public double fScore;
	public (int x, int y) comeFrom;
	
	public Node(int weight) {
		this.weight = weight;
		this.gScore = Double.PositiveInfinity;
		this.fScore = Double.PositiveInfinity;
		this.comeFrom = (0, 0);
	}
}