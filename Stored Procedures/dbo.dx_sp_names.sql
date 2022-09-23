SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   procedure [dbo].[dx_sp_names] (@proc_name varchar(255))
as

SELECT  sysobjects.name AS proc_name 
FROM sysobjects 
WHERE     (sysobjects.name LIKE @proc_name or sysobjects.name LIKE 'dx_%') and sysobjects.type ='P'
ORDER BY sysobjects.name

GO
GRANT EXECUTE ON  [dbo].[dx_sp_names] TO [public]
GO
