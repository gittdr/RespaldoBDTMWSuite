SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_update_post_processing] @proc_name varchar(50), @key_value varchar(12), @tp_id varchar(20) = ''
as

/*******************************************************************************************************************  
  Object Description:
  dx_update_post_processing

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

declare @nproc nvarchar(128)
select @nproc = N'exec ' + convert(nvarchar(50), @proc_name) + N' ''' + convert(nvarchar(12), @key_value) + N''''
if isnull(@tp_id,'') > ''
	select @nproc = @nproc + N', ''' + convert(nvarchar(20), @tp_id) + N''''

exec sp_executesql @nproc

if @@error <> 0
	return -1
else
	return 1

GO
GRANT EXECUTE ON  [dbo].[dx_update_post_processing] TO [public]
GO
