 //changeeee stuff
class ProcessDeleter extends Routine{
 
  SOS os;

 
  ProcessDeleter(String c, String d, SOS os_){
    super(c, d);
    os = os_;
  }
 
  void startRoutine(){
    os.interruptsEnabled = false;
    os.physicalAddress = baseAddress;
  }
 
  void endRoutine(){
     os.runningProcess.state = EXITING;

    //Find the partition
    for (int i=0; i<os.partitionTable.size(); i++) {
      if (os.partitionTable.get(i).baseAddress == os.runningProcess.baseAddress) {
        //delete data from that partition
        for (int j=0; j<os.partitionTable.get(i).size; j++) {
          os.PC.RAM[j+os.runningProcess.baseAddress] = '_';
        }  
        //Set partition as free
        os.processTable.remove(os.runningProcess);
        
        os.partitionTable.get(i).isFree=true; //this is needed when you delete a proces but dont shift the list blah blah
        //delete the process from the process table
        //check if next free, if so , change size (size of 1 is size of both) then delete the 2nd 
        if(os.partitionTable.get(i + 1).isFree){
          os.partitionTable.get(i).size += os.partitionTable.get(i + 1).size;
          os.partitionTable.remove(i + 1); 
        }
        //if one proces before the free one gets free
        if(os.partitionTable.get(i - 1).isFree){
          os.partitionTable.get(i - 1).size += os.partitionTable.get(i).size;
          os.partitionTable.remove(i); 
        }
        break;
      }
    }
  }
}
