//new
//changeeee stuff
class ProcessAdmit extends Routine{
 
  SOS os;
 
  ProcessAdmit(String c, String d, SOS os_){
    super(c, d);
    os = os_;
  }
 
  void startRoutine(){
    os.interruptsEnabled = false;
    os.physicalAddress = baseAddress;
  }
 
  void endRoutine(){
    //System.out.println("test \n test12 \n test");
    //if (os.tempPI!=null) {
      
    //    os.tempPI.state = READY;
    //    os.queue.add(os.tempPI);
    //    if (os.runningProcess==null) {
    //      os.kernel.get("Scheduler").startRoutine();
    //    }
    //}
    if (os.tempPI!=null) {
        os.tempPI.state = READY;
        os.queue.add(os.tempPI);
        if (os.runningProcess==null && os.requests.size()==0) {
          os.kernel.get("Scheduler").startRoutine();
        }
      }
      os.interruptsEnabled = true;
  }
}
