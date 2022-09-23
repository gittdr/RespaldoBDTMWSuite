SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 CREATE PROC [dbo].[getstoprefsstring] (@ord_hdrnumber int)   
AS  
/* 27908 returns a varchar with all the stop reference numbers for an order  
  
  PTS40260 recode Pauls into main source
*/  
BEGIN  
  
  Create table #StpNums (stp_number int NULL,stp_arrivaldate datetime)  
  
  Declare @nextstp int,@nextstpdate datetime,@nextseq int,@refs varchar(500)  
  Select @refs = ''  
  
  Insert into #stpNums  
  Select stp_number, stp_arrivaldate   
  From stops  
  Where ord_hdrnumber = @ord_hdrnumber  
  And stp_type = 'DRP'  
  And ord_hdrnumber > 0  
  
  Select @nextstpdate = Min(stp_arrivaldate)  
  From #StpNums  
  
  Select @nextstpdate = IsNull(@nextstpdate,'1950-01-02')  
  
  While @nextstpdate <> '1950-01-02'  
  BEGIN  
    Select @nextstp = Min(stp_number)  
    From #StpNums  
    Where stp_arrivaldate = @nextstpdate  
  
      Select @nextseq = Min(ref_sequence) From referencenumber  
      Where ref_table = 'stops' and ref_tablekey = @nextstp  
      and ref_type not in ('MAN','TF')  
  
      Select @nextseq = IsNull(@nextseq,0)  
  
      While @nextseq > 0  
      BEGIN  
         Select @refs = @refs + '('+name+') '+ref_number+', '  
         From referencenumber,labelfile  
         Where ref_table = 'stops'  
         And ref_tablekey = @nextstp  
         And ref_sequence = @nextseq  
         And labeldefinition = 'ReferenceNumbers'  
         And abbr = ref_type  
  
  
         Select @nextseq = Min(ref_sequence)  
         From referencenumber  
         Where ref_table = 'stops' and ref_tablekey = @nextstp  
         and ref_type not in ('MAN','TF')  
         and ref_sequence > @nextseq  
  
         Select @nextseq = IsNull(@nextseq,0)  
   
       END  
     Select @nextstpdate = Min(stp_arrivaldate)  
     From #StpNums  
     Where stp_arrivaldate > @nextstpdate  
  
      Select @nextstpdate = IsNull(@nextstpdate,'1950-01-02')  
  END  
  Drop table #StpNums  
  
  Select  Case When datalength(@refs) < 3 Then '' Else substring(@refs,1,datalength(@refs) - 2) End  
  
  
 END 
GO
GRANT EXECUTE ON  [dbo].[getstoprefsstring] TO [public]
GO
