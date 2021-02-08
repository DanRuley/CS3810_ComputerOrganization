import java.util.ArrayList;

/*
 * Assumptions: 1 cycle for cache hits
 * 
 * 1 + 10 + [1 cycle per byte] for cache misses
 * Total cache size must not exceed 840 bits
 */
public class CacheSimulation {

	public static void main(String[] args) {
		int[] addresses = new int[] { 4, 8, 12, 16, 20, 32, 36, 40, 44, 20, 32, 36, 40, 44, 64, 68, 4, 8, 12, 92, 96,
				100, 104, 108, 112, 100, 112, 116, 120, 128, 140, 144 };

		directMapped(addresses, 16, 4);
		directMapped(addresses, 8, 8);
		directMapped(addresses, 4, 16);
		directMapped(addresses, 2, 32);
		directMapped(addresses, 1, 64);

		fullyAssociative(addresses, 15, 4);
		fullyAssociative(addresses, 10, 8);
		fullyAssociative(addresses, 5, 16);
		fullyAssociative(addresses, 3, 32);
		fullyAssociative(addresses, 1, 64);

		// 16 row SA
		setAssociative(addresses, 16, 4, 1);
		// 8 row SA's
		setAssociative(addresses, 8, 4, 2);
		setAssociative(addresses, 8, 8, 1);
		// 4 row SA's
		setAssociative(addresses, 4, 4, 4);
		setAssociative(addresses, 4, 8, 2);
		setAssociative(addresses, 4, 16, 1);
		// 2 row SA's
		setAssociative(addresses, 2, 4, 8);
		setAssociative(addresses, 2, 8, 5);
		setAssociative(addresses, 2, 16, 2);
		setAssociative(addresses, 2, 32, 1);
		// 1 row SA's
		setAssociative(addresses, 1, 4, 16);
		setAssociative(addresses, 1, 8, 10);
		setAssociative(addresses, 1, 16, 5);
		setAssociative(addresses, 1, 32, 3);
		setAssociative(addresses, 1, 64, 1);
	}

	/**
	 * Simulates a Direct Mapped cache
	 * 
	 * @param addrs      - array of addresses to read/cache
	 * @param rows       - # rows in the cache
	 * @param block_size - # of bytes / block
	 */
	public static void directMapped(int[] addrs, int rows, int block_size) {

		double hits_total = 0;
		double misses_total = 0;
		int offset_bits = logbase2(block_size);
		int row_bits = logbase2(rows);

		int[] dm_cache = new int[rows];

		// First pass to populate the cache
		for (int i = 0; i < addrs.length; i++) {
			int tag = addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits + row_bits));
			int row = (addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits))) % rows;

			dm_cache[row] = tag;
		}

		// Second pass for the "real" analysis
		for (int i = 0; i < addrs.length; i++) {
			int tag = addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits + row_bits));
			int row = (addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits))) % rows;

			String result;
			if (dm_cache[row] == tag) {
				hits_total++;
				result = "hit from row " + row;
			} else {
				misses_total++;
				result = "miss - cached to row: " + row;
			}

			System.out.println("address: " + addrs[i] + ", tag: " + tag + ", result: " + result);

			dm_cache[row] = tag;
		}

		System.out.println("Direct Mapped Cache - rows: " + rows + "    blocksize: " + block_size + " bytes" + "\n"
				+ "Total misses: " + misses_total + ", Total hits: " + hits_total + "\nCPI for this set of addresses: "
				+ ((hits_total + misses_total * (11 + block_size)) / addrs.length) + "\n");
	}

	/**
	 * Simulates a Fully Associative cache.
	 * 
	 * @param addrs      - array of addresses to read/cache
	 * @param entries    - # entries in the cache
	 * @param block_size - # of bytes / block
	 */
	public static void fullyAssociative(int[] addrs, int entries, int block_size) {

		double hits_total = 0;
		double misses_total = 0;
		int offset_bits = logbase2(block_size);

		int[] fa_cache = new int[entries];

		for (int i = 0; i < fa_cache.length; i++) {
			fa_cache[i] = -1;
		}

		int j;

		// First pass to get things warmed up
		for (int i = 0; i < addrs.length; i++) {
			boolean hit = false;
			int tag = addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits));
			for (j = 0; j < fa_cache.length; j++) {

				if (fa_cache[j] == tag) {
					swap(fa_cache, tag, j);
					break;
				}
				if (!hit) {
					swap(fa_cache, tag, -1);
				}
			}
		}

		// Do it for real now!
		for (int i = 0; i < addrs.length; i++) {

			int tag = addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits));

			boolean hit = false;
			String result = "";
			for (j = 0; j < fa_cache.length; j++) {
				if (fa_cache[j] == tag) {
					swap(fa_cache, tag, j);
					result = "hit from entry " + j;
					hits_total++;
					hit = true;
					break;
				}
			}
			if (!hit) {
				swap(fa_cache, tag, -1);
				misses_total++;
				result = "miss - cached to entry: " + j;
			}

			System.out.println("address: " + addrs[i] + ", tag: " + tag + " , result: " + result);
		}
		System.out.println("Fully Associative Cache - entries: " + entries + "    blocksize: " + block_size + " bytes"
				+ "\n" + "Total misses: " + misses_total + ", Total hits: " + hits_total
				+ "\nCPI for this set of addresses: " + ((hits_total + misses_total * (11 + block_size)) / addrs.length)
				+ "\n");
	}

	/**
	 * Simulates a Set Associative cache.
	 * 
	 * @param addrs      - array of addresses to read/cache
	 * @param rows       - # rows in the cache
	 * @param block_size - # of bytes / block
	 * @param setsize    - how many entries there are in a set that corresponds to
	 *                   one row (e.g. for two-way, setsize = 2)
	 */
	public static void setAssociative(int[] addrs, int rows, int block_size, int set_size) {

		double hits_total = 0;
		double misses_total = 0;

		int offset_bits = logbase2(block_size);
		int row_bits = logbase2(rows);

//		int tagbits = (16 - offset_bits - row_bits);
//		int LRUbits = logbase2(set_size);
//		int SIZE = rows * (set_size * (block_size * 8 + tagbits + LRUbits + 1));
//		System.out.println(SIZE);
//		if (SIZE > 840) {
//			System.out.println("TOO BIG!!!!" + " rows: " + rows + " blocksize: " + block_size + " ways: " + set_size);
//			return;
//		}

		ArrayList<int[]> sa_cache = new ArrayList<>();

		// build up the array with a set for each row
		for (int i = 0; i < rows; i++) {
			sa_cache.add(new int[set_size]);
		}

		// first pass to populate the cache before analysis
		for (int i = 0; i < addrs.length; i++) {
			int tag = addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits + row_bits));
			int row = (addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits))) % rows;

			int[] rowcache = sa_cache.get(row);

			boolean hit = false;
			for (int j = 0; j < rowcache.length; j++) {

				if (rowcache[j] == tag) {
					swap(rowcache, tag, j);
					hit = true;
					break;
				}
			}
			if (!hit) {
				swap(rowcache, tag, -1);
			}
		}

		// second pass through the address array to perform the analysis.
		for (int i = 0; i < addrs.length; i++) {
			int tag = addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits + row_bits));
			int row = (addrs[i] / (int) Math.ceil(Math.pow(2, offset_bits))) % rows;

			int[] rowcache = sa_cache.get(row);

			String result = "";
			boolean hit = false;
			for (int j = 0; j < rowcache.length; j++) {
				if (rowcache[j] == tag) {
					swap(rowcache, tag, j);
					hit = true;
					hits_total++;
					result = "hit from row: " + row;
					break;
				}
			}
			if (!hit) {
				swap(rowcache, tag, -1);
				result = "miss - cached to row: " + row;
				misses_total++;
			}

			System.out.println("Address: " + addrs[i] + ", tag: " + tag + " , result: " + result);
		}

		System.out.println("Set Associative Cache - rows: " + rows + "    blocksize: " + block_size + " bytes    ways: "
				+ set_size + "\n" + "Total misses: " + misses_total + ", Total hits: " + hits_total
				+ "\nCPI for this set of addresses: " + ((hits_total + misses_total * (11 + block_size)) / addrs.length)
				+ "\n");

	}

	/*
	 * Places the tag at the end of the array and shifts everything else down to
	 * represent it as being used less recently.
	 */
	private static void swap(int[] associative_cache, int tag, int index) {

		// If tag was already the most recently used and it's in the set, do nothing
		if (index == associative_cache.length - 1)
			return;

		// If tag was not in the set, shift everything left and replace the oldest entry
		// with tag
		else if (index == -1) {
			for (int i = 0; i < associative_cache.length - 1; i++) {
				int tmp = associative_cache[i];
				associative_cache[i] = associative_cache[i + 1];
				associative_cache[i + 1] = tmp;
			}
			associative_cache[associative_cache.length - 1] = tag;
			return;
		}

		// Tag is in the set but it's not the most recent - adjust accordingly.
		else {
			for (int i = index; i < associative_cache.length - 1; i++) {
				int temp = associative_cache[i + 1];
				associative_cache[i + 1] = tag;
				associative_cache[i] = temp;
			}
		}
	}

	/*
	 * Return the log base 2 of input as an integer (seriously, the Java math
	 * library doesn't have this?!)
	 */
	private static int logbase2(int x) {
		return (int) (Math.log(x) / Math.log(2) + 1e-10);
	}

}
