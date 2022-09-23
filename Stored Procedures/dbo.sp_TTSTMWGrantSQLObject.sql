SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO









CREATE      Procedure [dbo].[sp_TTSTMWGrantSQLObject](@roleorlogin varchar(255),@sqlobject varchar(255),@objecttype varchar(255),@objectsource varchar(255),@grantorrevoke varchar(255),@reportname varchar(255))
--Execute sp_TTSTMWGrantSQLObject 'cft','sp_TTSTMWmileagesummary','P','CannedReport','Grant','Mileage Summary'


As

Declare @granttype varchar(255)
Declare @sql varchar(8000)
Declare @objectid int

If @objectsource = 'CannedReport' 
Begin
       Select identity(int,1,1) as ObjectID,rao_object 
       into   #TempCannedObjects
       from   MR_CannedReportsAndObjects
       Where  rao_reportname = @reportname
End

If @grantorrevoke = 'Grant' 
Begin

 Select @granttype = Case @objecttype
    
                 --View
                     	 When 'V' Then
                         	'Select'
           
                --Proc
                     	 When 'P' Then
                        	'Execute'
           
                --Other objects
                     	 Else
                        	'All'
           
                     End
    

	    If @objectsource = 'CannedReport' 
		Begin
			
			Select @objectid = Min(ObjectID)
			from  #TempCannedObjects
			
			While @objectid Is Not Null
	  		Begin
				Select @sqlobject = (select rao_object from #TempCannedObjects where ObjectID = @objectid) 
				Set @sql = 'GRANT ' + @granttype + ' ON ' + @sqlobject + ' TO ' + '[' + @roleorlogin + ']'
				
				Exec (@SQL)

				Set @SQL = 'Delete from MR_Permissions where perm_grantee = ' + '''' + @roleorlogin + '''' +  ' And perm_object = ' + '''' +  @sqlobject + '''' +  ' And perm_objectsource = ' + '''' +  @objectsource + ''''
          
             		   	Exec (@SQL)
          
				Set @SQL = 'Insert into MR_Permissions (perm_grantee,perm_object,perm_objectsource,perm_objecttype,perm_reportname) Values (' + '''' + @roleorlogin + '''' + ',' + '''' + @sqlobject + '''' + ',' + '''' +  @objectsource + '''' + ','  + '''' +  @objecttype + '''' + ','  + '''' +  @reportname + '''' + ')'                                

                                Exec (@SQL)

				Select
	     				@objectid = min(objectid)
	    			From
	      				#TempCannedObjects
	    			Where
	      				objectid > @objectid
		
			End

			Drop Table #TempCannedObjects		

		End
		Else
		Begin
			   Set @sql = 'GRANT ' + @granttype + ' ON ' + @sqlobject + ' TO ' + '[' + @roleorlogin + ']'
		           Exec (@SQL)
			
			   Set @SQL = 'Delete from MR_Permissions where perm_grantee = ' + '''' + @roleorlogin + '''' +  ' And perm_object = ' + '''' +  @sqlobject + '''' +  ' And perm_objectsource = ' + '''' +  @objectsource + ''''
          
            		   Exec (@SQL)
          
                           Set @SQL = 'Insert into MR_Permissions (perm_grantee,perm_object,perm_objectsource,perm_objecttype,perm_reportname) Values (' + '''' + @roleorlogin + '''' + ',' + '''' + @sqlobject + '''' + ',' + '''' +  @objectsource + '''' + ','  + '''' +  @objecttype + '''' + ','  + '''' +  @reportname + '''' + ')'
          
                           Exec (@SQL)

		End

         

End
Else
Begin
	
	If @objectsource = 'CannedReport' 
	Begin

			Select @objectid = Min(ObjectID)
			from  #TempCannedObjects
			
			While @objectid Is Not Null
	  		Begin
				Select @sqlobject = (select rao_object from #TempCannedObjects where ObjectID = @objectid) 
				
				Set @SQL = 'REVOKE ALL ON ' + @sqlobject + ' TO ' + '[' + @roleorlogin + ']'

        			Exec (@SQL)				

				Set @SQL = 'Delete from MR_Permissions where perm_grantee = ' + '''' + @roleorlogin + '''' + ' And perm_object = ' + '''' +  @sqlobject + '''' + ' And perm_objectsource = ' + '''' +  @objectsource + ''''
          
        			Exec (@SQL)

				Select
	     				@objectid = min(objectid)
	    			From
	      				#TempCannedObjects
	    			Where
	      				objectid > @objectid
		
			End

			
			Drop Table #TempCannedObjects	

				

	End


			Set @SQL = 'REVOKE ALL ON ' + @sqlobject + ' TO ' + '[' + @roleorlogin + ']'

        		Exec (@SQL)
    
        		Set @SQL = 'Delete from MR_Permissions where perm_grantee = ' + '''' + @roleorlogin + '''' + ' And perm_object = ' + '''' +  @sqlobject + '''' + ' And perm_objectsource = ' + '''' +  @objectsource + ''''
          
        		Exec (@SQL)

End










GO
