<!-- edit avatar -->

%from functions import *

<a name="gravatar"></a>
<h2>الصورة الشخصية</h2>
<p>يعتمد موقعنا على تقنية Gravatar للصور الشخصية، إذا كنت مشتركًا في الخدمة من قبل فستظهر صورتك بالأسفل، وإلا ستظهر صورة ظل مجهول.</p>
<p>تعتمد خدمة Gravatar على البريد الإلكتروني الذي أدخلته سابقًا في عملية التسجيل، فإذا لم تكن مشتركًا في Gravatar يمكنك الضغط على زر "إضافة/تغيير الصورة الشخصية" وستظهر لك نافذة للاشتراك أو إذا كنت مشتركًا ستظهر نافذة لتغيير الصورة.</p>
<br />
<img src="{{get_avatar(usr, 200)}}" alt="الصورة الشخصية" />
<br /><br />
<a href="http://ar.gravatar.com/emails" target="_blank" style="text-decoration: none;"><button id="registerGravatar" style="font-size: 1.25em;">إضافة/تغيير الصورة الشخصية</button></a>