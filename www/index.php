<html>
   <head>
      <title>checkPlanning</title>
      <style type="text/css">
         body { font-family: sans-serif; }
      </style>
      <script type="text/javascript" src="/inc/jquery-1.12.0.min.js"></script>
      <script type="text/javascript">
         $(document).ready(function() {

         });
      </script>
   </head>
   <body>
      <h1>Planning search</h1>
      <?php
         function getAddresses($url,$week) {
            $addresses = array();
            $fields = array( 'lbxWeeklyListToShow' => $week );
            $fields_string = NULL;
            foreach($fields as $key=>$value) { $fields_string .= $key.'='.$value.'&'; }
            rtrim($fields_string, '&');
            $ch = curl_init();
            curl_setopt($ch,CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch,CURLOPT_POST, count($fields));
            curl_setopt($ch,CURLOPT_POSTFIELDS, $fields_string);
            $result = curl_exec($ch);
            //print_r($result);

            $plans = explode('<table',$result);
            array_shift($plans);
            array_shift($plans);
            foreach($plans as $plan) {
               $cells = explode('<td',$plan);
               $x = 0;
               foreach($cells as $cell) {
                  $cell = trim(strip_tags('<td'.$cell));
                  if($x==1) { $addresses[] = $cell; $x = 0;}
                  if($cell=='Site Address:') { $x = 1; }
               }
            }
            curl_close($ch);
            return $addresses;
         }
         $addresses = array();
         $found = array();
         $addresses = getAddresses('http://www.wyreforest.gov.uk/fastweb/weeklylistapp.asp','-2');
         $addresses = array_merge($addresses,getAddresses('http://www.wyreforest.gov.uk/fastweb/weeklylistapp.asp','-1'));
         $addresses = array_merge($addresses,getAddresses('http://www.wyreforest.gov.uk/fastweb/weeklylistapp.asp','0'));
         $addresses = array_merge($addresses,getAddresses('http://www.wyreforest.gov.uk/fastweb/weeklylistdec.asp','0'));
         $addresses = array_merge($addresses,getAddresses('http://www.wyreforest.gov.uk/fastweb/weeklylistdec.asp','-1'));
         $addresses = array_merge($addresses,getAddresses('http://www.wyreforest.gov.uk/fastweb/weeklylistdec.asp','-2'));
         foreach($addresses as $address) { if(stripos($address, 'cookley')!==false) { $found[] = $address; }}
         echo '<p>We found '.count($addresses).' planning applications/decisions, '.count($found).' contained "Cookley".</p>';
         if(count($found)>0) {
            foreach($found as $item) { echo '<p>'.$item.'</p>'; }
         }
      ?>
   </body>
</html>
