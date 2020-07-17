import java.util.*;
class SOS {
  Hardware PC;
  int physicalAddress;
  int currentAddress;
  LinkedList<Partition> partitionTable;
  ArrayList<ProcessInfo>processTable;
  ArrayList<ProcessInfo> queue;
  ArrayList<Integer>requests;
  ProcessInfo runningProcess;
  ProcessInfo tempPI;
  int tempPartitionIndex;
  String tempProcess;
  String state; //text explining what is happening
  boolean interruptsEnabled;
  HashMap<String, Routine> kernel;
  int pindex;
  int endTime;
  int idleTime;
  int contextSwitchTime;
  int utilisation;
  int freeSpace;
  
  //important for  ProcessBuilder, ProcessAmit
  //String process;
  //int creationIndex, aIndex;
  //ProcessInfo aProcess;

  SOS(Hardware h) {
    PC = h;
    partitionTable = new LinkedList <Partition>();
    requests = new ArrayList<Integer>();
    kernel = new HashMap<String, Routine>();
    kernel.put("Idle", new Idle("+1", "IDLE", this) );
    kernel.put("Scheduler", new FCFS("++2", "FCFS scheduler", this) );
    //LJ added this
    kernel.put("Memory Manager", new MManager("+++3", "Memory Manager", this) );
    //LJ added this after creating processbuilder
    kernel.put("Create Process", new ProcessBuilder("++4", "Create Process", this));
    //LJ added after creating ProcesADmit
    kernel.put("Admit Process", new ProcessAdmit("++5", "Admit Process", this));
    //Lj
    kernel.put("Delete Process", new ProcessDeleter("++6", "Delete Process", this));
    interruptsEnabled = true;
    state = kernel.get("Idle").description;

    //Set memory partitions
    //2 partitions for OS thother 6 for user processes (2+6=8)
    //partitionTable = new Partition[8]; 

    //calculate the total code length of the os 
    int osCodeLength =0;
    for (Routine r : kernel.values()) {
      osCodeLength += r.code.length();
    }

    //calculate the partition size of the user partitions (equal)
    int partitionSize = (PC.RAM.length - osCodeLength);
    // (partitionTable.size()-kernel.size()); lj new

    //create the OS partitions and load the os programs
    int b =0;
    b = loadOSRoutine(kernel.get("Idle"), b, 0);
    b = loadOSRoutine(kernel.get("Scheduler"), b, 1);
    b = loadOSRoutine(kernel.get("Memory Manager"), b, 2);
    b = loadOSRoutine(kernel.get("Create Process"), b, 3);
    b = loadOSRoutine(kernel.get("Admit Process"), b, 4);
    b = loadOSRoutine(kernel.get("Delete Process"), b, 5);

    //create the user partitions
    //for (int i=kernel.size(); i<partitionTable.size(); i++) {
    //  partitionTable[i] = new Partition(b, partitionSize);
    //  b += partitionSize;
    //} lj new
    
    partitionTable.add(new Partition(b, partitionSize));

    //Set process Table
    processTable = new ArrayList<ProcessInfo>();
    queue = new ArrayList<ProcessInfo>();
    physicalAddress = kernel.get("Idle").baseAddress;
    currentAddress = physicalAddress;
    runningProcess=null;
  }//END OF CONSTRUCTOR

  int loadOSRoutine(Routine r, int ba, int partitionIndex) {
    r.baseAddress = ba;
    Partition curr = new Partition(ba, r.code.length());
    
    curr.isFree=false;
    
    partitionTable.add(curr);
    
    for (int j=0; j<r.code.length(); j++) {
      PC.RAM[ba+j] = r.code.charAt(j);
    }
    
    return ba+r.code.length();
  }


  void loadProgram(int p) {
    if (interruptsEnabled) {
      if (runningProcess != null) {
        runningProcess.state = READY;
        queue.add(0,runningProcess);
        runningProcess=null;
      }
      tempProcess = PC.HDD.get(p)+"hhhsss";
      kernel.get("Memory Manager").startRoutine();
      //int pindex = runMemoryManager(tempProcess.length());
      
    } else {
      requests.add(p);
    }
  }  

  //int runMemoryManager(int requestedSize) {
  //  int result =-1; //-1 did not find a partition
  //  for (int i=0; i<partitionTable.length; i++) {
  //    if (partitionTable[i].isFree && partitionTable[i].size>=requestedSize) { 
  //      result = i;
  //      break;
  //    }
  //  }
  //  return result;
  //}

  //ProcessInfo createProcess(int i, String p) {
  //  ProcessInfo pi = new ProcessInfo(partitionTable[i].baseAddress, p.length(), PC.clock);
  //  processTable.add(pi);
  //  for (int j=0; j<p.length(); j++) {
  //    PC.RAM[j+partitionTable[i].baseAddress] = p.charAt(j);
  //  }  
  //  partitionTable[i].isFree = false; 
  //  return pi;
  //}

  //void admitProcess(ProcessInfo p) {
  //  if (p!=null) {
  //    p.state = READY;
  //    queue.add(p);
  //    if (runningProcess==null) {
  //      kernel.get("Scheduler").startRoutine();
  //    }
  //  }
  //}
  
  //void deleteProcess(ProcessInfo pi) {
  //  pi.state = EXITING;

  //  //Find the partition
  //  for (int i=0; i<partitionTable.length; i++) {
  //    if (partitionTable[i].baseAddress == pi.baseAddress) {
  //      //delete data from that partition
  //      for (int j=0; j<partitionTable[i].size; j++) {
  //        PC.RAM[j+pi.baseAddress] = '_';
  //      }  
  //      //Set partition as free
  //      partitionTable[i].isFree=true;
  //      //delete the process from the process table
  //      processTable.remove(pi);
  //      break;
  //    }
  //  }
  //}


  void step() {
    if (interruptsEnabled && !requests.isEmpty()) {
      if (runningProcess != null) {
        runningProcess.state = READY;
        queue.add(runningProcess);
        runningProcess=null;
      }
      loadProgram(requests.get(0));
      requests.remove(0);
    }
    currentAddress = physicalAddress;
    println("curr address is "+currentAddress);
    PC.fetchInstruction(currentAddress);
    char c = PC.executeInstruction();
    println("fetched "+c);
    
    if(currentAddress >= 0 && currentAddress <= 1){
      idleTime++;
      System.out.println("Idle Time: "+ idleTime);
    } 
    else if(currentAddress >= 2 && currentAddress <= 17 ){
      contextSwitchTime++;
      System.out.println("Context Switch Time: " + contextSwitchTime);
    }
    else{
      utilisation++;
      System.out.println("Utilisation: " + utilisation);
    }
    
    if (c=='*') {

      //everytime a * is loaded call the scheduler
      state="Executing user process "+runningProcess.PID;
      runningProcess.counter++;
      physicalAddress = runningProcess.baseAddress+runningProcess.counter;
      runningProcess.state = READY;
      queue.add(os.runningProcess);
      kernel.get("Scheduler").startRoutine();
    } else if (c=='$') {
      state="Exiting user process "+runningProcess.PID;
      runningProcess.state = EXITING;
      //deleteProcess(runningProcess);
      kernel.get("Delete Process").startRoutine();
      endTime = PC.clock;
      int turnAroundTime = endTime - runningProcess.loadTime;
      int responseTime = runningProcess.startTime - runningProcess.loadTime;
      System.out.println("turnaround time" + turnAroundTime);
      System.out.println("response time " + responseTime);
      System.out.println("stat time " + runningProcess.startTime);
      System.out.println("end time " + endTime);
      System.out.println("Load Time " + runningProcess.loadTime);
      //kernel.get("Scheduler").startRoutine();
      
    } else if ( c=='@') {
      runningProcess.counter++;
      //physicalAddress = runningProcess.baseAddress+runningProcess.counter;
      state="Blocking user process "+runningProcess.PID;
      runningProcess.state = BLOCKED;
      runningProcess.blockTime = PC.clock;
      runningProcess = null;
      kernel.get("Scheduler").startRoutine();
    } 
    else if(c==kernel.get("Memory Manager").command){//CHANGE #2
      kernel.get("Memory Manager").endRoutine();
      if (pindex != -1) {
        kernel.get("Create Process").startRoutine(); 
        //kernel.get("Create Process").endRoutine();  
        //admitProcess(tempPI);
       } else{
         //invoke compactor here
         //concatinateFreeSpaces();
       }
       
       
    }
    else if(c == kernel.get("Create Process").command){
      kernel.get("Create Process").endRoutine();  
      //admitProcess(tempPI);
      kernel.get("Admit Process").startRoutine();
    }
    else if(c == kernel.get("Admit Process").command){
      //System.out.println("test \n test \n test");
      kernel.get("Admit Process").endRoutine();
      //System.out.println("ab \n ab \n ab");
    }
    else if(c == kernel.get("Delete Process").command){
      kernel.get("Delete Process").endRoutine();
      kernel.get("Scheduler").startRoutine();
    }
    else if (c=='+') {
      physicalAddress++;
    } else if (c==kernel.get("Idle").command) {
      state=kernel.get("Idle").description;
      kernel.get("Idle").endRoutine();
    } else if (c==kernel.get("Scheduler").command) {
      kernel.get("Scheduler").endRoutine();
      if (runningProcess!=null) {
        physicalAddress = runningProcess.baseAddress+runningProcess.counter;
        state="Finished scheduling. Selected user process "+runningProcess.PID;
      } else {
        state="Finished scheduling. No user process found. Going to idle";
        kernel.get("Idle").startRoutine();
      }
    }
  }
  
  //void concatinateFreeSpaces(){
  //  int nextBAddress;
  //  for (int i = 1; i < partitionTable.size(); i++){
  //    if(partitionTable.get(i).isFree){
  //      freeSpace += partitionTable.get(i).size;
  //      nextBAddress = partitionTable.get(i - 1).baseAddress + partitionTable.get(i - 1).size;
  //      partitionTable.get(i+1).baseAddress = nextBAddress;
  //      partitionTable.remove(i);
  //    } 
  //  }
  //  int bAEmpty = partitionTable.getLast().size + partitionTable.getLast().baseAddress;
  //  partitionTable.add(new Partition(bAEmpty, freeSpace));
  //}
}
