# Read this before making changes to Git Repo for PyABSA or anything that requires pip install

#### Create a venv before downloading dependencies
1. Downloading venv for create virtual environment (windows)
```
pip install virtualenv 
```
2. Go to localation of git repo and create venv
```
cd "location"
python -m venv myenv
```
3. Activate venv
```
myenv\Scripts\activate

## if there is an error on execution policy run line below and try again
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```
4. Download any packages required to run app
```
pip install -r requirements.txt

OR

pip install --package-name--
```
5. If additional packages were downloaded, save in requirements.txt
```
pip freeze > requirements.txt
```
6. Deactivate venv once done
```
deactivate
```