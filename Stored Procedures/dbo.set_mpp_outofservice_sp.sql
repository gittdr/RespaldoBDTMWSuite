SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[set_mpp_outofservice_sp]
as

SET NOCOUNT ON

declare @mpp_id varchar(8)
declare cur CURSOR LOCAL for
   select mpp_id
     from manpowerprofile 
    where mpp_id in (select exp_id 
                       from expiration 
                      where exp_code = 'OUT' and exp_idtype = 'DRV' and 
                            expiration.exp_expirationdate <= GETDATE())
          and not mpp_status = 'OUT'

open cur

fetch next from cur into @mpp_id

while @@FETCH_STATUS = 0 BEGIN
	
    exec drv_expstatus @mpp_id
    
    fetch next from cur into @mpp_id
END

close cur
deallocate cur

--PTS 
ENDPROC:
	
GO
GRANT EXECUTE ON  [dbo].[set_mpp_outofservice_sp] TO [public]
GO
