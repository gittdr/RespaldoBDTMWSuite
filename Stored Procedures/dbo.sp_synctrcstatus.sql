SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[sp_synctrcstatus]
as

declare @tractor varchar(20)

declare recorrestatus cursor
for (select trc_number from tractorprofile where trc_status <> 'OUT')

OPEN recorrestatus  
  
FETCH NEXT FROM recorrestatus  
INTO @tractor 
  
WHILE @@FETCH_STATUS = 0  
BEGIN  


exec
[dbo].[trc_expstatus]  @tractor
print 'Procesando status unidad: ' + @tractor + '..'


    FETCH NEXT FROM recorrestatus   
    INTO @tractor 
END   
CLOSE recorrestatus ;  
DEALLOCATE recorrestatus ; 
GO
