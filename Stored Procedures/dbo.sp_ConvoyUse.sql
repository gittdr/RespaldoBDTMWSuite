SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[sp_ConvoyUse]
as

declare @driver varchar(20)  

DECLARE ConvoyUse CURSOR
for (select mpp_id from manpowerprofile where mpp_status <> 'OUT')

OPEN ConvoyUse

fetch next from ConvoyUse into @driver

WHILE @@FETCH_STATUS = 0  
BEGIN  


		update manpowerprofile set    mpp_gps_heading  = (select dbo.fnc_convoyuse(@driver)) * 100
		where mpp_status <> 'OUT' and mpp_id = @driver


	FETCH NEXT FROM ConvoyUSe 
    INTO @driver

END
CLOSE ConvoyUse  
    DEALLOCATE ConvoyUse 
        -- Get the next driver.  
    


	
GO
