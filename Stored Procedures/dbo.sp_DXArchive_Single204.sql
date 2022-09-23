SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[sp_DXArchive_Single204]

As

select * from dx_archive
where dx_Processed = 'LOADED'
  and dx_sourcedate = 
      (select top 1 dx_sourcedate 
            from dx_archive chk 
            where dx_processed = 'LOADED' 
                  and (dx_sourcedate is not null) 
            order by dx_sourcedate 
      )

GO
GRANT EXECUTE ON  [dbo].[sp_DXArchive_Single204] TO [public]
GO
