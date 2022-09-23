SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
If Transcode = 'L' indicates a full load of all drivers

   Modification Log

DPETE created for PTS 

*/
Create Procedure [dbo].[TMI_imagingrecord_200]  
As
--DTS when sql returns messages due to inserts
SET NOCOUNT ON

DECLARE @mppid varchar(8),@transcode char(1)
Create table #TMIDriver (dimage varchar(1000) NULL)

--Create table 
/*  considered passing the trans code then decided to just go thru the list
If @transcode = 'L'
   Insert into #TMIDriver
	Select '20002' 
  + Convert(char(10),mpp_id)
  + Convert(Char(25),Case mpp_actg_type When 'P' Then '0' Else '1' End)
  + 'QTY       ' -- cannot determin from driver Id how he will be paid
  + replicate (' ',31) -- do not have the data benifit class, payroll rep, non compny driver
  + 'A'
  From manpowerprofile Where mpp_id = @driverId and DateDiff(day,mpp_terminationdt,Getdate() ) < 0

Else
  BEGIN 
*/
    DECLARE drvlist CURSOR FOR
    SELECT Distinct mpp_id,idrl_Transcode 
    FROM ImageDriverList
    ORDER BY mpp_id,idrl_Transcode

    OPEN drvlist

	 FETCH NEXT FROM drvlist INTO @mppid,@transcode
    WHILE @@FETCH_STATUS = 0
      BEGIN
       Insert Into #TMIDriver
       Select '20002' 
       + Convert(char(10),@mppid)
       + Convert(Char(25),Case IsNull(mpp_actg_type,'') When 'P' Then '0' Else '1' End)
       + 'QTY       ' -- cannot determin from driver Id how he will be paid
       + replicate (' ',31) -- do not have the data benifit class, payroll rep, non compny driver
       + @transcode
       From manpowerprofile Where mpp_id = @mppid

       DELETE FROM ImageDriverList Where mpp_id = @mppid 
       FETCH NEXT FROM driverlist INTO @mppid,@transcode
     END
--  END

Select * from #TMIDriver Where dimage is not null

Drop table #TMIDriver
GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_200] TO [public]
GO
