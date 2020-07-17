//changeeee stuff
class ProcessBuilder extends Routine{
 
  SOS os;
  ProcessInfo pi;

 
  ProcessBuilder(String c, String d, SOS os_){
    super(c, d);
    os = os_;
  }
 
  void startRoutine(){
    os.interruptsEnabled = false;
    os.physicalAddress = baseAddress;
  }
 
  void endRoutine(){
    pi = new ProcessInfo(os.partitionTable.get(os.pindex).baseAddress, os.tempProcess.length(), os.PC.clock);
    os.processTable.add(pi);
    for (int j=0; j<os.tempProcess.length(); j++) {
      os.PC.RAM[j+os.partitionTable.get(os.pindex).baseAddress] = os.tempProcess.charAt(j);
    }
    int newPartitionAddress = os.tempProcess.length() + os.partitionTable.get(os.pindex).baseAddress; 
    Partition newPartition = new Partition(newPartitionAddress, os.partitionTable.get(os.pindex).size - os.tempProcess.length());
    //split partiton, get as much as you need, leave the rest.
    os.partitionTable.get(os.pindex).size = os.tempProcess.length();
    os.partitionTable.get(os.pindex).isFree = false;
    //add it at the back
    os.partitionTable.add(os.pindex + 1, newPartition);
    //os.partitionTable.add(new Partition(newPartitionAddress, os.PC.RAM[]));
    //os.partitionTable.get(os.pindex).isFree = false;
    //added this to fix smth
    os.tempPI = pi;
  }
}
