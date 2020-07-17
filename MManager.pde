//changeeee stuff
class MManager extends Routine{
 
  SOS os;
 
  MManager(String c, String d, SOS os_){
    super(c, d);
    os = os_;
  }
 
  void startRoutine(){
    os.interruptsEnabled = false;
    os.physicalAddress = baseAddress;
  }
 
  void endRoutine(){
 
  os.pindex = -1; //-1 did not find a partition
    for (int i=0; i<os.partitionTable.size(); i++) {
      if (os.partitionTable.get(i).isFree && os.partitionTable.get(i).size>=os.tempProcess.length()) {
        os.pindex = i;
        break;
      }
    }
  }
}
