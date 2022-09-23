SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  Proc [dbo].[TMMessageDumpLast24Hours]
	(@hoursBack int =24)
As
Select 	CASE WHEN LEN(IsNuLL(FromName,'MISSING'))=0 THEN 'MISSING' ELSE IsNuLL(FromName,'MISSING')END FrmName, 
	ReadByName ReadBy, 
        Convert(Varchar(500),msgImage) MessageBody, 
        Errored = 
                (Select 
                        count(*) 
                from 
                        dbo.tblMsgProperties Errorprp 
                where 
                        t.OrigMsgSN=Errorprp.msgsn 
                        and 
                        Errorprp.PropSN = 6 
                ), 
        ErrorDesc= 
        Right( 
                ISNULL( 
                (Select 
                        Replace ( 

                                Replace( 
                                min(convert(varchar(512),Description)),  char(10),'|') 

                        ,char(13),'|')                  

                        Description 
                From 
                        dbo.tblErrorData ErrTbl, 
                        dbo.tblMsgProperties Errorprp   
                where 
                        T.OrigMsgSN=Errorprp.msgsn 
                        and 
                        Errorprp.PropSN = 6 
                        AND 
                        Errorprp.Value= ErrTbl.ErrListID 
                ) 
                ,'') 
        ,120),
	T.OrigMsgSN 
        ,t.* ,tblMessages.* 

from tblMessages (NOLOCK),TblMsgShareData T (NOLOCK)
where dtsent >dateAdd(hh,-@hoursBack,Getdate()) and tblMessages.SN =t.origMsgSN 

Order by DtSent Desc


GO
